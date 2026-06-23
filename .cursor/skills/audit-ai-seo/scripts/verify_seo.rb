#!/usr/bin/env ruby
# frozen_string_literal: true

# Live SEO + LLM discoverability verifier (stdlib only).
#
# Requires site-pages.json — lists which pages on your site to check.
# Copy site-pages.json from the audit-ai-seo skill and edit paths for your site.
#
# Usage:
#   ruby verify_seo.rb https://example.com
#   ruby verify_seo.rb https://example.com ./site-pages.json
#   SITE=https://example.com ruby verify_seo.rb
#
# Looks for site-pages.json next to this script, then ./site-pages.json in cwd.
#
# References:
#   https://evilmartians.com/chronicles/how-to-make-your-website-visible-to-llms
#   https://ruby.evilmartians.com/
#   https://evilmartians.com/skills/llms-visibility.md

require "json"
require "net/http"
require "openssl"
require "uri"

class VerifySeo
  Result = Data.define(:name, :status, :detail) # :pass, :warn, :fail

  AI_BOTS = %w[GPTBot ClaudeBot PerplexityBot CCBot Google-Extended].freeze
  CONFIG_FILENAME = "site-pages.json"

  CONFIG_DEFAULTS = {
    "check_llms_full_txt" => true,
    "require_feed" => false,
    "require_json_ld" => true,
    "require_markdown_negotiation" => true
  }.freeze

  def initialize(base_url, config_path: nil)
    @base = normalize_base(base_url)
    @config = load_config!(config_path)
    @results = []
  end

  def run
    check_robots
    check_sitemap
    check_llms_txt
    check_llms_full_txt if @config["check_llms_full_txt"]
    check_feed if @config["require_feed"]

    @config["md_paths"].each { |path| check_md_mirror(path) }
    @config["section_indexes"].each { |pair| check_section_index(pair) }

    @config["html_paths"].each { |path| check_html_page(path) }

    print_report
    @results.any? { |r| r.status == :fail } ? 1 : 0
  end

  private

  def normalize_base(url)
    uri = URI.parse(url)
    raise ArgumentError, "URL must be http or https" unless uri.is_a?(URI::HTTP)

    path = uri.path.to_s
    path = "/" if path.empty?
    path = path.sub(%r{/+\z}, "")
    URI("#{uri.scheme}://#{uri.host}#{uri.port && uri.port != uri.default_port ? ":#{uri.port}" : ""}#{path == "" ? "" : path}")
  end

  def self.resolve_config_path(explicit_path)
    if explicit_path
      return explicit_path if File.file?(explicit_path)

      abort "Config not found: #{explicit_path}"
    end

    script_dir = File.dirname(File.expand_path($PROGRAM_NAME))
    candidates = [
      File.join(script_dir, CONFIG_FILENAME),
      File.join(script_dir, "..", CONFIG_FILENAME),
      File.join(Dir.pwd, CONFIG_FILENAME),
      File.join(Dir.pwd, "script", CONFIG_FILENAME)
    ]

    found = candidates.find { |p| File.file?(p) }
    return found if found

    abort <<~MSG
      Missing #{CONFIG_FILENAME} — copy it from the audit-ai-seo skill and list your site's pages to check.

      Expected one of:
        #{candidates.join("\n        ")}

      Usage: ruby verify_seo.rb https://example.com [path/to/site-pages.json]
    MSG
  end

  def load_config!(path)
    resolved = self.class.resolve_config_path(path)
    raw = JSON.parse(File.read(resolved))
    config = CONFIG_DEFAULTS.merge(raw)

    %w[html_paths section_indexes].each do |key|
      abort "#{CONFIG_FILENAME}: missing required key \"#{key}\"" unless config.key?(key)
    end

    config["md_paths"] = derive_md_paths(config)

    config
  rescue JSON::ParserError => e
    abort "#{CONFIG_FILENAME} parse error: #{e.message}"
  end

  def derive_md_paths(config)
    explicit = config["md_paths"]
    return explicit if explicit.is_a?(Array) && explicit.any?

    config["html_paths"].map { |path| html_path_to_md(path) } +
      config["section_indexes"].map { |pair| html_path_to_md(pair["html"]) }
  end

  def absolute(path)
    path = "/#{path}" unless path.start_with?("/")
    URI.join(@base.to_s + "/", path.sub(%r{\A/}, ""))
  end

  def fetch(uri, headers: {}, method: :get, body: nil, max_redirects: 5)
    current = uri
    redirects = 0

    loop do
      http = Net::HTTP.new(current.host, current.port)
      http.use_ssl = current.scheme == "https"
      http.open_timeout = 15
      http.read_timeout = 20
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      klass = method == :head ? Net::HTTP::Head : Net::HTTP::Get
      request = klass.new(current)
      headers.each { |k, v| request[k] = v }
      request.body = body if body

      response = http.request(request)

      if response.is_a?(Net::HTTPRedirection) && redirects < max_redirects
        redirects += 1
        current = URI.join(current, response["location"])
        next
      end

      return {
        uri: current,
        code: response.code.to_i,
        headers: response.each_header.to_h,
        body: response.body.to_s
      }
    end
  end

  def pass(name, detail = "ok")
    @results << Result.new(name:, status: :pass, detail:)
  end

  def warn(name, detail)
    @results << Result.new(name:, status: :warn, detail:)
  end

  def fail(name, detail)
    @results << Result.new(name:, status: :fail, detail:)
  end

  def check_robots
    res = fetch(absolute("/robots.txt"))
    unless res[:code] == 200
      fail("robots.txt", "HTTP #{res[:code]}")
      return
    end

    body = res[:body]
    pass("robots.txt", "HTTP 200")

    if body.match?(/Sitemap:\s*\S+/i)
      pass("robots.txt sitemap directive", "present")
    else
      warn("robots.txt sitemap directive", "missing Sitemap: line")
    end

    if body.match?(/Content-Signal:/i)
      pass("robots.txt Content-Signal", "present")
    else
      warn("robots.txt Content-Signal", "missing (recommended for AI crawlers)")
    end

    AI_BOTS.each do |bot|
      if body.match?(/User-agent:\s*#{Regexp.escape(bot)}[\s\S]*?Disallow:\s*\/\s*$/im)
        fail("robots.txt #{bot}", "Disallow: /")
      else
        pass("robots.txt #{bot}", "not blocked")
      end
    end
  rescue StandardError => e
    fail("robots.txt", e.message)
  end

  def check_sitemap
    res = fetch(absolute("/sitemap.xml"))
    if res[:code] == 200 && res[:body].include?("<urlset")
      pass("sitemap.xml", "valid XML urlset")
    else
      fail("sitemap.xml", "HTTP #{res[:code]} or invalid XML")
    end
  rescue StandardError => e
    fail("sitemap.xml", e.message)
  end

  def check_llms_txt
    res = fetch(absolute("/llms.txt"))
    body = res[:body].to_s
    if res[:code] == 200 && body.start_with?("#")
      pass("llms.txt", "HTTP 200, Markdown H1")
    else
      fail("llms.txt", "HTTP #{res[:code]} or missing H1")
    end
  rescue StandardError => e
    fail("llms.txt", e.message)
  end

  def check_llms_full_txt
    res = fetch(absolute("/llms-full.txt"))
    if res[:code] == 200 && res[:body].to_s.length > 500
      pass("llms-full.txt", "HTTP 200, #{res[:body].length} bytes")
    else
      warn("llms-full.txt", "HTTP #{res[:code]} or very short body")
    end
  rescue StandardError => e
    warn("llms-full.txt", e.message)
  end

  def check_feed
    res = fetch(absolute("/feed.xml"))
    if res[:code] == 200 && res[:body].include?("<feed")
      pass("feed.xml", "Atom/RSS present")
    else
      warn("feed.xml", "HTTP #{res[:code]} or not Atom")
    end
  rescue StandardError => e
    warn("feed.xml", e.message)
  end

  def check_md_mirror(path)
    res = fetch(absolute(path))
    body = res[:body].to_s
    if res[:code] == 200 && !body.strip.empty? && !body.lstrip.start_with?("<!")
      ct = res[:headers]["content-type"].to_s
      detail = ct.include?("markdown") ? "text/markdown" : "body looks like Markdown"
      pass("MD mirror #{path}", detail)
    else
      fail("MD mirror #{path}", "HTTP #{res[:code]} or HTML response")
    end

    link = res[:headers]["link"].to_s
    if link.match?(/rel=.alternate.*text\/html/i)
      pass("MD Link header #{path}", "points to HTML")
    else
      warn("MD Link header #{path}", "missing rel=alternate type=text/html")
    end
  rescue StandardError => e
    fail("MD mirror #{path}", e.message)
  end

  def check_section_index(pair)
    html_path = pair["html"]
    md_path = pair["md"]
    check_md_mirror(md_path)
    check_html_page(html_path, expected_md: md_path)
  end

  def check_html_page(path, expected_md: nil)
    res = fetch(absolute(path))
    unless res[:code] == 200
      fail("HTML #{path}", "HTTP #{res[:code]}")
      return
    end

    body = res[:body].to_s
    pass("HTML #{path}", "HTTP 200")

    titles = body.scan(/<title[^>]*>/i).length
    if titles == 1
      pass("HTML #{path} single title", "ok")
    else
      fail("HTML #{path} title count", "found #{titles}, want 1")
    end

    descriptions = body.scan(/<meta[^>]+name=["']description["']/i).length
    if descriptions == 1
      pass("HTML #{path} meta description", "ok")
    else
      fail("HTML #{path} meta description", "found #{descriptions}, want 1")
    end

    if body.match?(/<link[^>]+rel=["']canonical["']/i)
      pass("HTML #{path} canonical", "present")
    else
      warn("HTML #{path} canonical", "missing")
    end

    %w[og:title og:description og:image].each do |prop|
      if body.match?(/property=["']#{Regexp.escape(prop)}["']/i)
        pass("HTML #{path} #{prop}", "present")
      else
        warn("HTML #{path} #{prop}", "missing")
      end
    end

    if @config["require_json_ld"]
      if body.include?("application/ld+json") && body.include?("schema.org")
        pass("HTML #{path} JSON-LD", "present")
      else
        fail("HTML #{path} JSON-LD", "missing application/ld+json or schema.org @context")
      end
    end

    md_path = expected_md || html_path_to_md(path)
    if body.match?(/rel=["']alternate["'][^>]+type=["']text\/markdown["']/i) ||
       body.match?(/type=["']text\/markdown["'][^>]+rel=["']alternate["']/i)
      pass("HTML #{path} link alternate markdown", "present")
    else
      fail("HTML #{path} link alternate markdown", "missing")
    end

    if body.match?(/visually-hidden/i) && body.match?(/Markdown version of this page/i)
      pass("HTML #{path} LLM pointer", "visually-hidden div")
    else
      warn("HTML #{path} LLM pointer", "missing visually-hidden Markdown hint")
    end

    link_header = res[:headers]["link"].to_s
    if link_header.match?(/rel=.alternate.*text\/markdown/i)
      pass("HTML #{path} Link header", "markdown alternate")
    else
      warn("HTML #{path} Link header", "missing Link: ... text/markdown")
    end

    if @config["require_markdown_negotiation"]
      check_markdown_negotiation(path, md_path)
    end
  rescue StandardError => e
    fail("HTML #{path}", e.message)
  end

  def check_markdown_negotiation(html_path, _md_path)
    check_negotiation_returns_markdown(html_path)
    check_negotiation_rejects_unsupported_accept(html_path)
    check_negotiation_honors_q_values(html_path)
    check_negotiation_wildcard_returns_html(html_path)
  end

  def check_negotiation_returns_markdown(html_path)
    res = fetch(absolute(html_path), headers: { "Accept" => "text/markdown, text/html;q=0.5" })
    body = res[:body].to_s.strip
    vary = res[:headers]["vary"].to_s.downcase

    if res[:code] == 200 && !body.start_with?("<!") && !body.start_with?("<html")
      if vary.include?("accept")
        pass("Negotiation #{html_path} markdown", "Markdown body + Vary: Accept")
      else
        warn("Negotiation #{html_path} markdown", "Markdown body but missing Vary: Accept")
      end
    elsif res[:code] == 406
      fail("Negotiation #{html_path} markdown", "HTTP 406 but Accept allows text/html fallback")
    else
      fail(
        "Negotiation #{html_path} markdown",
        "expected Markdown body, got HTTP #{res[:code]} (edge function / server may be missing)"
      )
    end
  rescue StandardError => e
    fail("Negotiation #{html_path} markdown", e.message)
  end

  def check_negotiation_honors_q_values(html_path)
    res = fetch(absolute(html_path), headers: { "Accept" => "text/html, text/markdown;q=0.5" })
    body = res[:body].to_s.strip

    if res[:code] == 200 && (body.start_with?("<!") || body.start_with?("<html"))
      pass("Negotiation #{html_path} q-values", "HTML wins when text/html;q implicit > markdown;q=0.5")
    else
      fail(
        "Negotiation #{html_path} q-values",
        "expected HTML when Accept: text/html, text/markdown;q=0.5, got HTTP #{res[:code]}"
      )
    end
  rescue StandardError => e
    fail("Negotiation #{html_path} q-values", e.message)
  end

  def check_negotiation_wildcard_returns_html(html_path)
    res = fetch(absolute(html_path), headers: { "Accept" => "*/*" })
    body = res[:body].to_s.strip

    if res[:code] == 200 && (body.start_with?("<!") || body.start_with?("<html"))
      pass("Negotiation #{html_path} wildcard", "*/* returns HTML (text/markdown not named)")
    elsif res[:code] == 200 && !body.start_with?("<!")
      fail(
        "Negotiation #{html_path} wildcard",
        "Accept: */* must not return Markdown unless text/markdown is explicit"
      )
    else
      fail("Negotiation #{html_path} wildcard", "expected HTML for Accept: */*, got HTTP #{res[:code]}")
    end
  rescue StandardError => e
    fail("Negotiation #{html_path} wildcard", e.message)
  end

  def check_negotiation_rejects_unsupported_accept(html_path)
    res = fetch(absolute(html_path), headers: { "Accept" => "application/json" })
    body = res[:body].to_s.strip

    if res[:code] == 406
      pass("Negotiation #{html_path} unsupported Accept", "HTTP 406 Not Acceptable")
    elsif res[:code] == 200 && (body.start_with?("<!") || body.start_with?("<html"))
      fail(
        "Negotiation #{html_path} unsupported Accept",
        "HTTP 200 HTML — must return 406 when Accept is only application/json (RFC 9110)"
      )
    else
      fail(
        "Negotiation #{html_path} unsupported Accept",
        "HTTP #{res[:code]} — expected 406 for Accept: application/json"
      )
    end
  rescue StandardError => e
    fail("Negotiation #{html_path} unsupported Accept", e.message)
  end

  def html_path_to_md(path)
    normalized = path.sub(%r{/index\.html\z}, "").sub(%r{/+\z}, "")
    normalized = "/" if normalized.empty?
    return "/index.md" if normalized == "/"
    return "/guide.md" if normalized == "/guide"
    return "/blog.md" if normalized == "/blog"

    "#{normalized}.md"
  end

  def print_report
    puts
    puts "SEO + LLM discoverability report"
    puts "Site: #{@base}"
    puts "-" * 60

    grouped = { pass: [], warn: [], fail: [] }
    @results.each { |r| grouped[r.status] << r }

    grouped[:fail].each { |r| puts "FAIL  #{r.name} — #{r.detail}" }
    grouped[:warn].each { |r| puts "WARN  #{r.name} — #{r.detail}" }
    grouped[:pass].each { |r| puts "PASS  #{r.name} — #{r.detail}" }

    puts "-" * 60
    puts "Pass: #{grouped[:pass].length}  Warn: #{grouped[:warn].length}  Fail: #{grouped[:fail].length}"
    puts
    puts "Optional external scanners:"
    puts "  https://acceptmarkdown.com"
    puts "  https://isitagentready.com"
    puts "  https://ruby.evilmartians.com/"
  end
end

if __FILE__ == $PROGRAM_NAME
  base = ARGV.find { |a| a.match?(%r{\Ahttps?://}) } || ENV["SITE"]
  abort "Usage: ruby verify_seo.rb https://example.com [site-pages.json]" unless base

  config_path = ARGV.find { |a| a.end_with?(".json") }
  exit VerifySeo.new(base, config_path: config_path).run
end

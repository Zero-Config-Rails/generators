module SeoDiscoverability
  module PathMapping
    module_function

    def html_to_markdown(html_path)
      normalized = html_path.to_s.sub(%r{/index\.html\z}, "").sub(%r{/+\z}, "")
      normalized = "/" if normalized.empty?

      case normalized
      when "/" then "/index.md"
      else "#{normalized}.md"
      end
    end

    def markdown_to_html(md_path)
      normalized = md_path.to_s.sub(%r{/+\z}, "")
      return "/" if normalized == "/index.md"

      base = normalized.delete_suffix(".md")
      base.empty? ? "/" : base
    end

    def markdown_path?(path)
      path.to_s.end_with?(".md")
    end
  end
end

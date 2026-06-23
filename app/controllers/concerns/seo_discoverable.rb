module SeoDiscoverable
  extend ActiveSupport::Concern

  included do
    before_action :negotiate_seo_format
    after_action :set_seo_negotiation_headers, if: :seo_discoverable_response?
  end

  private

  def render_seo_markdown
    body = seo_markdown_body

    if body.blank?
      head :not_found
      return
    end

    render markdown: body
  end

  def seo_markdown_body
    SeoDiscoverability::MarkdownBuilder.build(seo_html_path)
  end

  def seo_html_path
    request.path
  end

  def negotiate_seo_format
    return if explicit_markdown_request?

    representation = SeoDiscoverability::AcceptParser.parse(request.headers["Accept"])

    if representation.html_q.zero? && representation.markdown_q.zero?
      response.headers["Vary"] = "Accept"
      head :not_acceptable
      return
    end

    if !representation.markdown_named || representation.html_q > representation.markdown_q
      request.format = :html
    elsif representation.markdown_q >= representation.html_q
      request.format = :md
    end
  end

  def explicit_markdown_request?
    params[:format].to_s == "md" || request.path.end_with?(".md")
  end

  def seo_discoverable_response?
    response.successful? && SeoDiscoverability::Catalog.known_html_path?(seo_html_path)
  end

  def set_seo_negotiation_headers
    response.headers["Vary"] = merge_vary(response.headers["Vary"], "Accept")

    link =
      if request.format.md?
        %(<#{seo_html_path}>; rel="alternate"; type="text/html")
      else
        md_path = SeoDiscoverability::PathMapping.html_to_markdown(seo_html_path)
        %(<#{md_path}>; rel="alternate"; type="text/markdown")
      end

    existing = response.headers["Link"].to_s
    response.headers["Link"] = existing.present? ? "#{existing}, #{link}" : link
  end

  def merge_vary(existing, value)
    values = existing.to_s.split(",").map(&:strip).reject(&:empty?)
    values << value unless values.include?(value)
    values.join(", ")
  end
end

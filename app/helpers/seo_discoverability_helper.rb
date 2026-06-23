module SeoDiscoverabilityHelper
  VISUALLY_HIDDEN_STYLE =
    "position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;" \
    "clip:rect(0,0,0,0);white-space:nowrap;border:0;"

  def seo_canonical_url
    SeoDiscoverability::Site.absolute(request.path)
  end

  def seo_markdown_path
    SeoDiscoverability::PathMapping.html_to_markdown(request.path)
  end

  def seo_markdown_url
    SeoDiscoverability::Site.absolute(seo_markdown_path)
  end

  def seo_page_indexable?
    SeoDiscoverability::Catalog.known_html_path?(request.path)
  end

  def seo_json_ld
    return unless seo_page_indexable?

    payload =
      case request.path
      when "/" then website_json_ld
      when %r{\A/rails_generators/([^/]+)\z} then rails_generator_json_ld(::Regexp.last_match(1))
      when %r{\A/install/([^/]+)\z} then gem_installer_json_ld(::Regexp.last_match(1))
      end

    return if payload.blank?

    tag.script(payload.to_json.html_safe, type: "application/ld+json")
  end

  def seo_markdown_alternate_tag
    return unless seo_page_indexable?

    tag.link(rel: "alternate", type: "text/markdown", href: seo_markdown_path)
  end

  def seo_markdown_pointer
    return unless seo_page_indexable?

    content_tag(
      :div,
      "A Markdown version of this page is available at #{seo_markdown_url}.",
      class: "visually-hidden",
      style: VISUALLY_HIDDEN_STYLE,
      aria: { hidden: "true" }
    )
  end

  private

  def website_json_ld
    {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => SeoDiscoverability::Site::NAME,
      "url" => SeoDiscoverability::Site::URL,
      "description" => SeoDiscoverability::Site::DESCRIPTION,
      "potentialAction" => {
        "@type" => "SearchAction",
        "target" => "#{SeoDiscoverability::Site::URL}/?q={search_term_string}",
        "query-input" => "required name=search_term_string"
      }
    }
  end

  def rails_generator_json_ld(generator_id)
    return unless RailsGenerators::ConfigurationsHelper::GENERATOR_IDS.include?(generator_id)

    meta =
      if generator_id == "app"
        RailsGenerators::ConfigurationsHelper::APP_META
      else
        RailsGenerate::Registry.meta(generator_id)
      end

    {
      "@context" => "https://schema.org",
      "@type" => "WebApplication",
      "name" => generator_id == "app" ? meta["tool_name"] : "#{meta["title"]} Generator",
      "description" => meta["description"],
      "url" => SeoDiscoverability::Site.absolute("/rails_generators/#{generator_id}"),
      "applicationCategory" => "DeveloperApplication",
      "operatingSystem" => "Web"
    }
  end

  def gem_installer_json_ld(identifier)
    generator = Generator.active.find_by(identifier:)
    return unless generator

    {
      "@context" => "https://schema.org",
      "@type" => "SoftwareApplication",
      "name" => generator.name || generator.identifier.humanize.titleize,
      "description" => generator.short_description.presence || generator.description,
      "url" => SeoDiscoverability::Site.absolute("/install/#{generator.identifier}"),
      "applicationCategory" => "DeveloperApplication",
      "operatingSystem" => "Web"
    }
  end
end

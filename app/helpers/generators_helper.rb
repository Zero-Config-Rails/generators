module GeneratorsHelper
  def generator_logo(generator)
    url = generator.logo_url

    return if url.blank?

    content_tag("div", class: "avatar mr-4") do
      content_tag("div", class: "w-8 rounded") do
        content_tag(
          "img",
          nil,
          src: url,
          alt: generator_title(generator) + " " + "logo"
        )
      end
    end
  end

  def generator_title(generator)
    generator.name || generator.identifier.humanize
  end
end

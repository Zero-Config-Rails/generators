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

  def user_guide_link_label(url, index:, total:)
    derived = derived_user_guide_label(url)

    if derived.present? && (total > 1 || derived != host_label(url))
      derived
    elsif total == 1
      "User guide"
    else
      "User guide #{index + 1}"
    end
  end

  private

  # convert the url to a more readable label
  # example: https://docs.avohq.io/4.0/installation.html -> Installation
  def derived_user_guide_label(url)
    uri = URI.parse(url)
    path_label = path_segment_label(uri)
    return path_label if path_label.present?

    host_label(url)
  rescue URI::InvalidURIError
    nil
  end

  def path_segment_label(uri)
    return if uri.path.blank? || uri.path == "/"

    segment = uri.path.split("/").reject(&:blank?).last
    segment = segment.sub(/\.[^.]+\z/, "")
    label = segment.tr("-_", " ").humanize
    label.presence if label.length > 2
  end

  def host_label(url)
    uri = URI.parse(url)
    uri.host&.sub(/\Awww\./, "")
  rescue URI::InvalidURIError
    nil
  end
end

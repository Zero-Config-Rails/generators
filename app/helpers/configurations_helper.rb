module ConfigurationsHelper
  def configuration_options(configurations)
    configurations
      .map do |configuration|
        default_value = configuration.default_value.to_s.presence || "nil"

        content_tag(:span, id: configuration.configuration_key) do
          " --#{configuration.configuration_key}=#{default_value}"
        end
      end
  end

  def configuration_title(configuration)
    configuration.label || configuration.configuration_key.humanize
  end
end

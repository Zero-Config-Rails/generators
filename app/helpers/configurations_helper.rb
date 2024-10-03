module ConfigurationsHelper
  def configuration_options(configurations)
    configurations
      .map do |configuration|
        default_value = configuration.default_value.to_s.presence || "nil"

        "--#{configuration.configuration_key}=#{default_value}"
      end
      .join(" ")
  end

  def configuration_title(configuration)
    configuration.label || configuration.configuration_key.humanize
  end
end

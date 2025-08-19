module ConfigurationsHelper
  def configuration_options(configurations)
    configurations.map do |configuration|
      default_value = configuration.default_value.to_s

      content_tag(
        :span,
        id: configuration.configuration_key,
        hidden: default_value.blank? || default_value == "false"
      ) do
        # should_hide_configuration_name is only present in the auto generated configurations for Rails app generator
        if configuration.try(:should_hide_configuration_name)
          " #{default_value}"
        else
          " --#{configuration.configuration_key}=#{default_value}"
        end
      end
    end
  end

  def configuration_title(configuration)
    configuration.label || configuration.configuration_key.titleize.humanize
  end
end

module ConfigurationsHelper
  SKIP_FIELD_TYPES = %w[list_field].freeze

  def configuration_options(configurations)
    configurations.reject { |c| SKIP_FIELD_TYPES.include?(configuration_fieldable_name(c)) }.map do |configuration|
      segment = initial_command_segment(configuration)
      hidden = segment.blank?

      content_tag(:span, segment, id: configuration.configuration_key, hidden: hidden)
    end
  end

  def configuration_title(configuration)
    configuration.label || configuration.configuration_key.titleize.humanize
  end

  def configuration_flag_format(configuration)
    configuration.try(:flag_format).presence || legacy_flag_format(configuration)
  end

  def configuration_fieldable_name(configuration)
    if configuration.respond_to?(:fieldable_name)
      configuration.fieldable_name
    else
      configuration.fieldable_type.underscore
    end
  end

  def name_placeholder(configuration)
    return unless configuration.configuration_key == "name"

    case @generator_id
    when "migration" then "AddTitleToPosts"
    when "controller" then "Posts"
    else "Post"
    end
  end

  private

  def initial_command_segment(configuration)
    if configuration.try(:should_hide_configuration_name)
      value = configuration.default_value.to_s
      return "" if value.blank?

      return " #{value}"
    end

    return "" if configuration_flag_format(configuration) == "positional_list"

    case configuration_flag_format(configuration)
    when "positive_boolean"
      configuration.fieldable.default_value ? " --#{configuration.configuration_key}" : ""
    when "negative_boolean"
      configuration.fieldable.default_value ? "" : negative_boolean_segment(configuration)
    when "value"
      value = configuration.fieldable&.default_value.to_s
      return "" if value.blank?

      " --#{configuration.configuration_key}=#{value}"
    else
      value = configuration.default_value.to_s
      return "" if value.blank? || value == "false"

      " --#{configuration.configuration_key}=#{value}"
    end
  end

  def negative_boolean_segment(configuration)
    prefix = configuration.try(:negative_prefix).presence || "skip"
    " --#{prefix}-#{configuration.configuration_key}"
  end

  def legacy_flag_format(configuration)
    return "value" unless configuration_fieldable_name(configuration) == "boolean_field"

    key = configuration.configuration_key
    return "positive_boolean" if key.start_with?("skip-")

    "value"
  end
end

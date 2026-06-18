module RailsGenerators
  module ConfigurationSupport
    ConfigurationStruct =
      Struct.new(
        :configuration_key,
        :label,
        :description,
        :is_required,
        :fieldable_name,
        :fieldable,
        :should_hide_configuration_name,
        :default_value,
        :flag_format,
        :negative_prefix,
        :is_prominent,
        keyword_init: true
      )

    FieldStruct = Struct.new(:type, :options, :default_value, keyword_init: true)
  end
end

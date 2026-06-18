module RailsGenerate
  module ConfigurationFormatter
    module_function

    def format_configuration(config)
      fieldable_str = format_fieldable(config)
      prominent = config.fetch(:is_prominent, false)

      <<~RUBY.strip
        ConfigurationStruct.new(
          configuration_key: #{config[:configuration_key].inspect},
          label: #{config[:label].inspect},
          description: #{config[:description].inspect},
          is_required: #{config[:is_required]},
          fieldable_name: #{config[:fieldable_name].inspect},
          fieldable: #{fieldable_str},
          should_hide_configuration_name: #{config.fetch(:should_hide_configuration_name, false)},
          default_value: #{config[:default_value].inspect},
          flag_format: #{config[:flag_format].inspect},
          negative_prefix: #{config[:negative_prefix].inspect},
          is_prominent: #{prominent}
        )
      RUBY
    end

    def format_fieldable(config)
      fieldable = config[:fieldable]
      case config[:fieldable_name]
      when "boolean_field"
        "FieldStruct.new(type: \"boolean_field\", default_value: #{fieldable[:default_value]})"
      when "dropdown_field"
        options_str =
          fieldable[:options]
            &.map { |opt| "[\"#{opt[0]}\", \"#{opt[1]}\"]" }
            &.join(", ") || ""
        "FieldStruct.new(type: \"dropdown_field\", options: [#{options_str}], default_value: #{fieldable[:default_value].inspect})"
      when "list_field"
        schema_call =
          case fieldable[:schema]
          when :rails_attribute then "ListField::Schemas.rails_attribute"
          when :space_separated then "ListField::Schemas.space_separated"
          else "ListField::Schemas.rails_attribute"
          end
        "FieldStruct.new(type: \"list_field\", default_value: [], options: #{schema_call})"
      else
        "FieldStruct.new(type: \"text_field\", default_value: #{fieldable[:default_value].inspect})"
      end
    end
  end
end

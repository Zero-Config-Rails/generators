# Auto-generated from `rails generate controller --help` via `rake rails_generate:parse[controller]`
# Generated on: 2026-06-10 10:18:04 UTC

module RailsGenerators::Generated::ControllerConfigurationsHelper
  include RailsGenerators::ConfigurationSupport

  def controller_generator_required_configurations
    [
      ConfigurationStruct.new(
        configuration_key: "name",
        label: "Name",
        description: "Resource or model name (CamelCase or snake_case)",
        is_required: true,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: true,
        default_value: "",
        flag_format: "positional",
        negative_prefix: nil,
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "actions",
        label: "Actions",
        description: "Controller actions (e.g. index show new create)",
        is_required: false,
        fieldable_name: "list_field",
        fieldable:
          FieldStruct.new(type: "list_field", default_value: [], options: ListField::Schemas.space_separated),
        should_hide_configuration_name: true,
        default_value: "",
        flag_format: "positional_list",
        negative_prefix: nil,
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "skip-routes",
        label: nil,
        description: "Don't add routes to config/routes.rb.",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: false),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "positive_boolean",
        negative_prefix: nil,
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "parent",
        label: nil,
        description: "The parent class for the generated controller #",
        is_required: false,
        fieldable_name: "text_field",
        fieldable:
          FieldStruct.new(
            type: "text_field",
            default_value: "ApplicationController"
          ),
        should_hide_configuration_name: false,
        default_value: "ApplicationController",
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "template-engine",
        label: nil,
        description: "Template engine to be invoked #",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: "erb"),
        should_hide_configuration_name: false,
        default_value: "erb",
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: true
      )
    ]
  end

  def controller_generator_optional_configurations
    [
      ConfigurationStruct.new(
        configuration_key: "skip-namespace",
        label: nil,
        description: "Skip namespace (affects only isolated engines) #",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: false),
        should_hide_configuration_name: false,
        default_value: "false",
        flag_format: "positive_boolean",
        negative_prefix: nil,
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "skip-collision-check",
        label: nil,
        description: "Skip collision check #",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: false),
        should_hide_configuration_name: false,
        default_value: "false",
        flag_format: "positive_boolean",
        negative_prefix: nil,
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "helper",
        label: nil,
        description: "Indicates when to generate helper #",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: true),
        should_hide_configuration_name: false,
        default_value: "true",
        flag_format: "negative_boolean",
        negative_prefix: "skip",
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "test-framework",
        label: nil,
        description: "Test framework to be invoked #",
        is_required: false,
        fieldable_name: "text_field",
        fieldable:
          FieldStruct.new(type: "text_field", default_value: "test_unit"),
        should_hide_configuration_name: false,
        default_value: "test_unit",
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: false
      )
    ]
  end
end

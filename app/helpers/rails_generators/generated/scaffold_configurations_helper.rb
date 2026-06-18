# Auto-generated from `rails generate scaffold --help` via `rake rails_generate:parse[scaffold]`
# Generated on: 2026-06-10 10:18:03 UTC

module RailsGenerators::Generated::ScaffoldConfigurationsHelper
  include RailsGenerators::ConfigurationSupport

  def scaffold_generator_required_configurations
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
        configuration_key: "columns",
        label: "Columns",
        description:
          "Columns as name:type[:index] pairs. Supports references (team:references), polymorphic (supplier:references{polymorphic}), limits (username:string{30}), decimal precision (price:decimal{10,2}), and specials (password:digest, auth_token:token).",
        is_required: false,
        fieldable_name: "list_field",
        fieldable:
          FieldStruct.new(type: "list_field", default_value: [], options: ListField::Schemas.rails_attribute),
        should_hide_configuration_name: true,
        default_value: "",
        flag_format: "positional_list",
        negative_prefix: nil,
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "api",
        label: nil,
        description:
          "Generate API-only controller and tests, with no view templates # -c, --scaffold-controller=NAME # Scaffold controller to be invoked #",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: false),
        should_hide_configuration_name: false,
        default_value: "false",
        flag_format: "positive_boolean",
        negative_prefix: nil,
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "migration",
        label: nil,
        description: "Indicates when to generate migration #",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: true),
        should_hide_configuration_name: false,
        default_value: "true",
        flag_format: "negative_boolean",
        negative_prefix: "skip",
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "parent",
        label: nil,
        description: "The parent class for the generated model #",
        is_required: false,
        fieldable_name: "text_field",
        fieldable:
          FieldStruct.new(
            type: "text_field",
            default_value: "ApplicationRecord"
          ),
        should_hide_configuration_name: false,
        default_value: "ApplicationRecord",
        flag_format: "value",
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
      )
    ]
  end

  def scaffold_generator_optional_configurations
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
        configuration_key: "force-plural",
        label: nil,
        description:
          "Do not singularize the model name, even if it appears plural # -o, --orm=NAME # ORM to be invoked #",
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
        configuration_key: "model-name",
        label: nil,
        description: "ModelName to be used",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "resource-route",
        label: nil,
        description: "Indicates when to generate resource route #",
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
        configuration_key: "timestamps",
        label: nil,
        description: "Indicates when to generate timestamps #",
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
        configuration_key: "indexes",
        label: nil,
        description: "Add indexes for references and belongs_to columns #",
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
        configuration_key: "primary-key-type",
        label: nil,
        description: "The type for primary key",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "database",
        label: nil,
        description:
          "The database for your model's migration. By default, the current environment's primary database is used.",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "value",
        negative_prefix: nil,
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
      ),
      ConfigurationStruct.new(
        configuration_key: "fixture",
        label: nil,
        description: "Indicates when to generate fixture #",
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
        configuration_key: "fixture-replacement",
        label: nil,
        description: "Fixture replacement to be invoked",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "system-tests",
        label: nil,
        description: "Generate system test files (set to 'true' to enable)",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "value",
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
        is_prominent: false
      ),
      ConfigurationStruct.new(
        configuration_key: "jbuilder",
        label: nil,
        description: "Indicates when to generate jbuilder #",
        is_required: false,
        fieldable_name: "boolean_field",
        fieldable: FieldStruct.new(type: "boolean_field", default_value: true),
        should_hide_configuration_name: false,
        default_value: "true",
        flag_format: "negative_boolean",
        negative_prefix: "skip",
        is_prominent: false
      )
    ]
  end
end

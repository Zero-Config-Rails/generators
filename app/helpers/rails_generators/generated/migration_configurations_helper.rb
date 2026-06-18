# Auto-generated from `rails generate migration --help` via `rake rails_generate:parse[migration]`
# Generated on: 2026-06-10 10:18:05 UTC

module RailsGenerators::Generated::MigrationConfigurationsHelper
  include RailsGenerators::ConfigurationSupport

  def migration_generator_required_configurations
    [
      ConfigurationStruct.new(
        configuration_key: "name",
        label: "Migration name",
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
        is_prominent: true
      ),
      ConfigurationStruct.new(
        configuration_key: "database",
        label: nil,
        description:
          "The database for your migration. By default, the current environment's primary database is used.",
        is_required: false,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field", default_value: ""),
        should_hide_configuration_name: false,
        default_value: nil,
        flag_format: "value",
        negative_prefix: nil,
        is_prominent: true
      )
    ]
  end

  def migration_generator_optional_configurations
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
        description:
          "Skip collision check # -o, --orm=NAME # ORM to be invoked #",
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
      )
    ]
  end
end

module RailsGenerators::AppHelper
  ConfigurationStruct =
    Struct.new(
      :configuration_key,
      :label,
      :description,
      :is_required,
      :fieldable_name,
      :options,
      :fieldable,
      :is_boolean_field,
      :should_hide_configuration_name,
      :default_value
    )
  FieldStruct = Struct.new(:type, :options, :default_value, keyword_init: true)

  def rails_app_generator_configurations
    [
      ConfigurationStruct.new(
        configuration_key: "application_name",
        description: "The name of your application",
        is_required: true,
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field"),
        should_hide_configuration_name: true
      ),
      ConfigurationStruct.new(
        configuration_key: "template",
        description:
          "Path to some application template (can be a filesystem path or URL)",
        fieldable_name: "text_field",
        fieldable: FieldStruct.new(type: "text_field")
      ),
      ConfigurationStruct.new(
        configuration_key: "database",
        description: "Preconfigure for selected database",
        fieldable_name: "dropdown_field",
        fieldable:
          FieldStruct.new(
            type: "dropdown_field",
            options: [
              %w[mysql MySQL],
              %w[trilogy Trilogy],
              %w[postgresql PostgreSQL],
              %w[sqlite3 SQLite]
            ],
            default_value: "sqlite3"
          ),
        default_value: "sqlite3"
      ),
      ConfigurationStruct.new(
        configuration_key: "javascript",
        description: "Choose JavaScript approach",
        fieldable_name: "dropdown_field",
        default_value: "importmap",
        fieldable:
          FieldStruct.new(
            type: "dropdown_field",
            options: [
              %w[importmap Importmap],
              %w[bun Bun],
              %w[webpack Webpack],
              %w[esbuild Esbuild],
              %w[rollup Rollup]
            ],
            default_value: "importmap"
          )
      ),
      ConfigurationStruct.new(
        configuration_key: "css",
        description:
          "Choose CSS processor. Check https://github.com/rails/cssbundling-rails for more options",
        fieldable_name: "dropdown_field",
        fieldable:
          FieldStruct.new(
            type: "dropdown_field",
            options: [
              %w[tailwind Tailwind],
              %w[bootstrap Bootstrap],
              %w[bulma Bulma],
              %w[postcss PostCSS],
              %w[sass Sass]
            ]
          )
      )
    ]
  end

  def rails_app_configuration_options(configurations)
    configurations.map do |configuration|
      default_value = configuration.default_value.to_s

      content_tag(
        :span,
        id: configuration.configuration_key,
        hidden: default_value.blank?
      ) do
        if configuration.should_hide_configuration_name
          " #{default_value}"
        else
          " --#{configuration.configuration_key}=#{default_value}"
        end
      end
    end
  end
end

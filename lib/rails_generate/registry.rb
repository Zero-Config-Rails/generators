module RailsGenerate
  class Registry
    GENERATORS_PATH = Rails.root.join("lib/rails_generate/generators.yml")

    class << self
      def all_ids
        meta.keys
      end

      def meta(generator_id = nil)
        @meta ||= YAML.safe_load_file(GENERATORS_PATH)
        generator_id ? @meta.fetch(generator_id) : @meta
      end

      def positional_configs(generator_id)
        configs = []
        configs << name_config(generator_id)

        case generator_id
        when "model", "scaffold", "resource", "migration"
          configs << list_config(:rails_attribute)
        when "controller"
          configs << list_config(:space_separated)
        end

        configs
      end

      def prominent_option_keys(generator_id)
        meta(generator_id).fetch("prominent_options", [])
      end

      private

      def name_config(generator_id)
        placeholder =
          case generator_id
          when "migration" then "AddTitleToPosts"
          when "controller" then "Posts"
          else "Post"
          end

        {
          configuration_key: "name",
          label: name_label(generator_id),
          description: "Resource or model name (CamelCase or snake_case)",
          is_required: true,
          fieldable_name: "text_field",
          fieldable: { type: "text_field", default_value: "" },
          should_hide_configuration_name: true,
          default_value: "",
          flag_format: "positional",
          negative_prefix: nil,
          is_prominent: true
        }
      end

      def name_label(generator_id)
        generator_id == "migration" ? "Migration name" : "Name"
      end

      def list_config(schema)
        case schema
        when :rails_attribute
          {
            configuration_key: "columns",
            label: "Columns",
            description:
              "Columns as name:type[:index] pairs. Supports references (team:references), polymorphic (supplier:references{polymorphic}), limits (username:string{30}), decimal precision (price:decimal{10,2}), and specials (password:digest, auth_token:token).",
            is_required: false,
            fieldable_name: "list_field",
            fieldable: { type: "list_field", default_value: [], schema: :rails_attribute },
            should_hide_configuration_name: true,
            default_value: "",
            flag_format: "positional_list",
            negative_prefix: nil,
            is_prominent: true
          }
        when :space_separated
          {
            configuration_key: "actions",
            label: "Actions",
            description: "Controller actions (e.g. index show new create)",
            is_required: false,
            fieldable_name: "list_field",
            fieldable: { type: "list_field", default_value: [], schema: :space_separated },
            should_hide_configuration_name: true,
            default_value: "",
            flag_format: "positional_list",
            negative_prefix: nil,
            is_prominent: true
          }
        end
      end
    end
  end
end

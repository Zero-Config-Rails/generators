module RailsGenerators
  module ConfigurationsHelper
    GENERATOR_IDS = %w[app model scaffold controller migration resource].freeze

    APP_META = {
      "title" => "Generate a new Rails App",
      "description" =>
        "Build a rails new command with the right flags - no man page archaeology.",
      "command" => "rails new",
      "tool_name" => "Rails App Generator"
    }.freeze

    def rails_generator_meta(generator_id)
      return APP_META if generator_id == "app"

      RailsGenerate::Registry.meta(generator_id)
    end

    def rails_generator_required_configurations(generator_id)
      case generator_id
      when "app" then rails_app_generator_configurations
      else send("#{generator_id}_generator_required_configurations")
      end
    end

    def rails_generator_optional_configurations(generator_id)
      case generator_id
      when "app" then optional_rails_app_generator_configurations
      else send("#{generator_id}_generator_optional_configurations")
      end
    end

    def rails_generator_valid?(generator_id)
      GENERATOR_IDS.include?(generator_id)
    end
  end
end

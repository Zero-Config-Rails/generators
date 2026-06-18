module RailsGenerate
  class ConfigurationWriter
    def initialize(generator_id:, configurations:, command:)
      @generator_id = generator_id
      @configurations = configurations
      @command = command
    end

    def write!
      FileUtils.mkdir_p(output_dir)
      File.write(output_path, file_content)
      puts "Generated #{output_path}"
    end

    def output_path
      output_dir.join("#{@generator_id}_configurations_helper.rb")
    end

    private

    def output_dir
      Rails.root.join("app/helpers/rails_generators/generated")
    end

    def file_content
      prominent_keys = Registry.prominent_option_keys(@generator_id)
      positional = Registry.positional_configs(@generator_id)
      parsed = @configurations.map { |c| c.merge(is_prominent: prominent_keys.include?(c[:configuration_key])) }

      prominent = positional + parsed.select { |c| c[:is_prominent] }
      optional = parsed.reject { |c| c[:is_prominent] }

      <<~RUBY
        # Auto-generated from `#{@command} --help` via `rake rails_generate:parse[#{@generator_id}]`
        # Generated on: #{Time.current.utc}

        module RailsGenerators::Generated::#{@generator_id.camelize}ConfigurationsHelper
          include RailsGenerators::ConfigurationSupport

          def #{@generator_id}_generator_required_configurations
            [
              #{prominent.map { |c| ConfigurationFormatter.format_configuration(c) }.join(",\n          ")}
            ]
          end

          def #{@generator_id}_generator_optional_configurations
            [
              #{optional.map { |c| ConfigurationFormatter.format_configuration(c) }.join(",\n          ")}
            ]
          end
        end
      RUBY
    end
  end
end

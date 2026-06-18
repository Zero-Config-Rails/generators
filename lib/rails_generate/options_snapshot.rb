module RailsGenerate
  class OptionsSnapshot
    BASELINE_PATH = Rails.root.join("config/rails_generator_options_baseline.yml")
    SOURCES = {
      "rails_new" => { type: :rails_new },
      "model" => { type: :generate, name: "model" },
      "scaffold" => { type: :generate, name: "scaffold" },
      "controller" => { type: :generate, name: "controller" },
      "migration" => { type: :generate, name: "migration" },
      "resource" => { type: :generate, name: "resource" }
    }.freeze

    class << self
      def capture
        sources = { "rails_new" => capture_rails_new }
        rails_version = nil

        VanillaRailsApp.with_app do |app_dir|
          rails_version = VanillaRailsApp.capture_in_app(app_dir, "bin/rails", "--version").match(/Rails (\S+)/)&.captures&.first

          SOURCES.each do |source, config|
            next if config[:type] == :rails_new

            help = VanillaRailsApp.capture_in_app(app_dir, "bin/rails", "generate", config[:name], "--help")
            sources[source] = { "option_keys" => HelpParser.new(help).option_keys.sort }
          end
        end

        {
          "rails_version" => rails_version,
          "captured_at" => Time.current.utc.iso8601,
          "sources" => sources
        }
      end

      def write_baseline!
        File.write(BASELINE_PATH, capture.to_yaml)
        puts "Wrote baseline to #{BASELINE_PATH}"
      end

      def check!
        baseline = YAML.safe_load_file(BASELINE_PATH)
        current = capture
        drift = compare(baseline, current)

        if drift.empty?
          puts "Rails generator options match baseline (Rails #{current['rails_version']})."
          return true
        end

        puts "Rails generator options drift detected (Rails #{current['rails_version']}):"
        drift.each do |source, changes|
          puts "  #{source}:"
          puts "    added: #{changes[:added].join(', ')}" if changes[:added].any?
          puts "    removed: #{changes[:removed].join(', ')}" if changes[:removed].any?
        end

        false
      end

      def drift_report
        baseline = YAML.safe_load_file(BASELINE_PATH)
        current = capture
        compare(baseline, current)
      end

      private

      def capture_rails_new
        { "option_keys" => HelpParser.new(VanillaRailsApp.rails_new_help).option_keys.sort }
      end

      def compare(baseline, current)
        drift = {}

        SOURCES.each_key do |source|
          baseline_keys = baseline.dig("sources", source, "option_keys") || []
          current_keys = current.dig("sources", source, "option_keys") || []
          added = current_keys - baseline_keys
          removed = baseline_keys - current_keys

          drift[source] = { added: added, removed: removed } if added.any? || removed.any?
        end

        drift
      end
    end
  end
end

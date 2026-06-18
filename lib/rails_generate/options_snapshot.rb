require "open3"

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
      def rails_new_help
        run_command("bin/rails", "new", "--help")
      end

      def generate_help(generator_name)
        run_command("bin/rails", "generate", generator_name, "--help")
      end

      def capture_snapshot
        sources = { "rails_new" => capture_rails_new }

        SOURCES.each do |source, config|
          next if config[:type] == :rails_new

          help = generate_help(config[:name])
          sources[source] = { "option_keys" => HelpParser.new(help).option_keys.sort }
        end

        {
          "rails_version" => rails_version,
          "captured_at" => Time.current.utc.iso8601,
          "sources" => sources
        }
      end

      def write_baseline!
        snapshot = capture_snapshot
        File.write(BASELINE_PATH, snapshot.to_yaml)
        puts "Wrote baseline to #{BASELINE_PATH} (Rails #{snapshot['rails_version']})"
      end

      def check!
        baseline = YAML.safe_load_file(BASELINE_PATH)
        current = capture_snapshot
        baseline_version = baseline["rails_version"]
        current_version = current["rails_version"]
        drift = compare(baseline, current)

        if baseline_version != current_version
          puts "Rails version changed: #{baseline_version} -> #{current_version}"
        else
          puts "Checking against baseline (Rails #{baseline_version})"
        end

        if drift.empty?
          if baseline_version != current_version
            puts "Generator options unchanged. Run `rake rails_options:baseline` to record Rails #{current_version}."
          else
            puts "Rails generator options match baseline."
          end
          return true
        end

        puts "Rails generator options drift detected (Rails #{current_version}):"
        drift.each do |source, changes|
          puts "  #{source}:"
          puts "    added: #{changes[:added].join(', ')}" if changes[:added].any?
          puts "    removed: #{changes[:removed].join(', ')}" if changes[:removed].any?
        end

        false
      end

      def drift_report
        baseline = YAML.safe_load_file(BASELINE_PATH)
        current = capture_snapshot
        compare(baseline, current)
      end

      private

      def rails_version
        run_command("bin/rails", "--version").match(/Rails (\S+)/)&.captures&.first
      end

      def run_command(*cmd)
        stdout, stderr, status = Open3.capture3(*cmd, chdir: Rails.root)
        unless status.success?
          raise "Command failed (#{cmd.join(" ")}): #{stderr}"
        end

        stdout
      end

      def capture_rails_new
        { "option_keys" => HelpParser.new(rails_new_help).option_keys.sort }
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

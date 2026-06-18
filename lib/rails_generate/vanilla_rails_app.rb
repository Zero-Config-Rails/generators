require "open3"
require "fileutils"
require "tmpdir"

module RailsGenerate
  class VanillaRailsApp
    class << self
      def rails_new_help
        Dir.chdir(Dir.tmpdir) { capture("rails", "new", "--help") }
      end

      def generate_help(generator_name)
        with_app { |app_dir| generate_help_in_app(app_dir, generator_name) }
      end

      def generate_help_in_app(app_dir, generator_name)
        capture_in_app(
          app_dir,
          "bin/rails",
          "generate",
          generator_name,
          "--help"
        )
      end

      def capture_in_app(app_dir, *cmd)
        stdout, stderr, status = Open3.capture3(*cmd, chdir: app_dir)
        unless status.success?
          raise "Command failed (#{cmd.join(" ")}): #{stderr}"
        end

        stdout
      end

      def with_app
        dir = Dir.mktmpdir("zcr_rails_parse_")
        create_app(dir)
        yield dir
      ensure
        FileUtils.rm_rf(dir) if dir && Dir.exist?(dir)
      end

      private

      def create_app(dir)
        success =
          Dir.chdir(Dir.tmpdir) do
            system(
              { "BUNDLE_GEMFILE" => "" },
              "rails",
              "new",
              dir,
              "--skip-git",
              "--minimal",
              "--skip-rubocop",
              "--skip-brakeman",
              "--skip-ci",
              "--skip-kamal",
              "--skip-dev-gems",
              "--skip-thruster",
              "--skip-solid",
              "--skip-asset-pipeline",
              out: File::NULL
            )
          end
        raise "Failed to create vanilla Rails app in #{dir}" unless success

        bundle_success =
          system(
            { "BUNDLE_GEMFILE" => "" },
            "bundle",
            "install",
            "--quiet",
            chdir: dir
          )
        raise "Failed to bundle install in #{dir}" unless bundle_success

        ensure_sprockets_manifest!(dir)
      end

      def ensure_sprockets_manifest!(dir)
        manifest_path = File.join(dir, "app/assets/config/manifest.js")
        return if File.exist?(manifest_path)

        FileUtils.mkdir_p(File.dirname(manifest_path))
        File.write(manifest_path, "//= link_tree ../images\n")
      end

      def capture(*cmd)
        env = cmd.first.is_a?(Hash) ? cmd.shift : { "BUNDLE_GEMFILE" => "" }
        stdout, stderr, status = Open3.capture3(env, *cmd)
        unless status.success?
          raise "Command failed (#{cmd.join(" ")}): #{stderr}"
        end

        stdout
      end
    end
  end
end

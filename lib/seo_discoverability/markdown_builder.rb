module SeoDiscoverability
  class MarkdownBuilder
    class << self
      def build(html_path)
        normalized = Catalog.normalize_html_path(html_path)

        case normalized
        when "/" then home_markdown
        when %r{\A/rails_generators/([^/]+)\z} then rails_generator_markdown(::Regexp.last_match(1))
        when %r{\A/install/([^/]+)\z} then gem_installer_markdown(::Regexp.last_match(1))
        end
      end

      def build_full_corpus
        sections = Catalog.html_paths.filter_map do |path|
          body = build(path)
          next if body.blank?

          "## #{Site.absolute(path)}\n\n#{body.strip}"
        end

        <<~MARKDOWN
          # #{Site::NAME}

          > #{Site::DESCRIPTION}

          #{sections.join("\n\n---\n\n")}
        MARKDOWN
      end

      def llms_index
        tool_links = Catalog.html_paths.drop(1).map do |path|
          title = page_title(path)
          "- [#{title}](#{path}): #{page_blurb(path)}"
        end

        <<~MARKDOWN
          # #{Site::NAME}

          > #{Site::DESCRIPTION}

          ## Tools

          - [Home](/): #{Site::TAGLINE}
          #{tool_links.join("\n")}
        MARKDOWN
      end

      private

      def home_markdown
        rails_tools = Catalog.generator_ids.map do |id|
          path = "/rails_generators/#{id}"
          "- [#{page_title(path)}](#{path}): #{page_blurb(path)}"
        end

        gem_tools = Generator.active.order(Arel.sql("COALESCE(name, identifier)")).map do |generator|
          path = "/install/#{generator.identifier}"
          "- [#{page_title(path)}](#{path}): #{page_blurb(path)}"
        end

        <<~MARKDOWN
          # #{Site::NAME}

          > #{Site::DESCRIPTION}

          #{Site::TAGLINE}

          Interactive configurators from [Zero Config Rails](#{NavigationHelper::ZCR_SITE_URL}). Build Rails generator commands, install gems with one line, and skip the manual wiring.

          ## Rails generators

          #{rails_tools.join("\n")}

          ## Gem installers

          Install gems with the `zcr-zen` CLI (`gem install zcr-zen`, then `zen add <gem>`).

          #{gem_tools.join("\n")}

          ## Full product

          [Zero Config Rails](#{NavigationHelper::ZCR_APP_URL}) compiles regression-tested Rails 8 SaaS apps with teams, Stripe billing, admin, and CI already wired.
        MARKDOWN
      end

      def rails_generator_markdown(generator_id)
        return unless Catalog.generator_ids.include?(generator_id)

        meta =
          if generator_id == "app"
            RailsGenerators::ConfigurationsHelper::APP_META
          else
            RailsGenerate::Registry.meta(generator_id)
          end

        title = generator_id == "app" ? meta["tool_name"] : "#{meta["title"]} Generator"
        command = generator_id == "app" ? "rails new <APP_NAME>" : meta["command"]

        <<~MARKDOWN
          # #{title}

          #{meta["description"]}

          **Command template:** `#{command}`

          Open the [interactive configurator](#{Site.absolute("/rails_generators/#{generator_id}")}) to tune flags and copy the final command.
        MARKDOWN
      end

      def gem_installer_markdown(identifier)
        generator = Generator.active.find_by(identifier:)
        return unless generator

        name = generator.name || generator.identifier.humanize.titleize
        description = generator.short_description.presence || generator.description.to_s
        command = "zen add #{generator.invocation_command}"

        guides =
          if generator.user_guide_urls.present?
            generator.user_guide_urls.map { |url| "- #{url}" }.join("\n")
          end

        <<~MARKDOWN
          # Install #{name}

          #{description}

          **Install command:** `#{command}`

          Use the [interactive installer](#{Site.absolute("/install/#{generator.identifier}")}) to configure options before running the command.
          #{guides.present? ? "\n## Guides\n\n#{guides}" : ""}
        MARKDOWN
      end

      def page_title(path)
        case path
        when "/" then Site::NAME
        when %r{\A/rails_generators/([^/]+)\z}
          id = ::Regexp.last_match(1)
          meta =
            if id == "app"
              RailsGenerators::ConfigurationsHelper::APP_META
            else
              RailsGenerate::Registry.meta(id)
            end
          id == "app" ? meta["tool_name"] : "#{meta["title"]} Generator"
        when %r{\A/install/([^/]+)\z}
          generator = Generator.active.find_by(identifier: ::Regexp.last_match(1))
          generator ? "Install #{generator.name || generator.identifier.humanize.titleize}" : path
        else
          path
        end
      end

      def page_blurb(path)
        case path
        when "/" then Site::TAGLINE
        when %r{\A/rails_generators/([^/]+)\z}
          id = ::Regexp.last_match(1)
          meta =
            if id == "app"
              RailsGenerators::ConfigurationsHelper::APP_META
            else
              RailsGenerate::Registry.meta(id)
            end
          meta["description"]
        when %r{\A/install/([^/]+)\z}
          generator = Generator.active.find_by(identifier: ::Regexp.last_match(1))
          generator&.short_description.presence || generator&.description.to_s || "Gem installer"
        else
          ""
        end
      end
    end
  end
end

module SeoDiscoverability
  class Catalog
    class << self
      def generator_ids
        RailsGenerators::ConfigurationsHelper::GENERATOR_IDS
      end

      def html_paths
        @html_paths = nil if Rails.env.development?

        @html_paths ||= begin
          paths = ["/"]
          generator_ids.each { |id| paths << "/rails_generators/#{id}" }
          Generator.active.order(Arel.sql("COALESCE(name, identifier)")).find_each do |generator|
            paths << "/install/#{generator.identifier}"
          end
          paths
        end
      end

      def markdown_paths
        html_paths.map { |path| PathMapping.html_to_markdown(path) }
      end

      def known_html_path?(path)
        html_paths.include?(normalize_html_path(path))
      end

      def known_markdown_path?(path)
        markdown_paths.include?(path)
      end

      def normalize_html_path(path)
        normalized = path.to_s.sub(%r{/index\.html\z}, "").sub(%r{/+\z}, "")
        normalized.empty? ? "/" : normalized
      end
    end
  end
end

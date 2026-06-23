module SeoDiscoverability
  class Publisher
    FILES = {
      "sitemap.xml" => -> { Sitemap.render },
      "llms.txt" => -> { MarkdownBuilder.llms_index },
      "llms-full.txt" => -> { MarkdownBuilder.build_full_corpus }
    }.freeze

    class << self
      def publish!(root: Rails.public_path)
        root.mkpath

        FILES.each do |filename, generator|
          path = root.join(filename)
          path.write(generator.call)
          Rails.logger.info { "[SeoDiscoverability] Wrote #{path}" } if defined?(Rails.logger)
        end
      end
    end
  end
end

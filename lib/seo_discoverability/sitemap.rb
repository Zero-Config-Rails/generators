require "erb"

module SeoDiscoverability
  class Sitemap
    def self.render
      urls =
        Catalog.html_paths.map do |path|
          priority = path == "/" ? "1.0" : "0.8"
          <<~XML.strip
            <url>
              <loc>#{ERB::Util.html_escape(Site.absolute(path))}</loc>
              <changefreq>weekly</changefreq>
              <priority>#{priority}</priority>
            </url>
          XML
        end

      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        #{urls.join("\n")}
        </urlset>
      XML
    end
  end
end

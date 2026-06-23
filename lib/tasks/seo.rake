namespace :seo do
  desc "Write sitemap.xml, llms.txt, and llms-full.txt to public/ (run after deploy or when generators change)"
  task publish: :environment do
    SeoDiscoverability::Publisher.publish!
    puts "Published SEO files to #{Rails.public_path}"
  end
end

require "test_helper"

class SeoPublishTaskTest < ActiveSupport::TestCase
  test "seo:publish writes sitemap and llms files to public" do
    SeoDiscoverability::Publisher.publish!

    assert File.exist?(Rails.public_path.join("sitemap.xml"))
    assert File.exist?(Rails.public_path.join("llms.txt"))
    assert File.exist?(Rails.public_path.join("llms-full.txt"))

    assert_includes Rails.public_path.join("sitemap.xml").read, "<urlset"
    assert Rails.public_path.join("llms.txt").read.start_with?("#")
  end
end

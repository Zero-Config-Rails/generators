require "test_helper"

class SeoDiscoverabilityTest < ActionDispatch::IntegrationTest
  setup do
    SeoDiscoverability::Publisher.publish!
  end

  test "sitemap is valid xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_includes response.body, "<urlset"
    assert_includes response.body, "<loc>https://generators.zeroconfigrails.com/</loc>"
  end

  test "llms.txt starts with markdown heading" do
    get "/llms.txt"
    assert_response :success
    assert response.body.start_with?("#")
  end

  test "index.md mirror returns markdown" do
    get "/index.md"
    assert_response :success
    assert_includes response.media_type, "markdown"
    assert_includes response.body, "# Zero Config Rails Generators"
    assert_match(/rel="alternate".*text\/html/i, response.headers["Link"].to_s)
  end

  test "rails generator md extension returns markdown" do
    get "/rails_generators/app.md"
    assert_response :success
    assert_includes response.media_type, "markdown"
    assert_includes response.body, "# Rails App Generator"
  end

  test "gem installer md extension returns markdown" do
    get "/install/devise.md"
    assert_response :success
    assert_includes response.media_type, "markdown"
    assert_includes response.body, "# Install Devise"
  end

  test "html home includes seo tags" do
    get "/"
    assert_response :success
    assert_select "link[rel=canonical]"
    assert_select 'link[rel=alternate][type="text/markdown"]'
    assert_includes response.body, "application/ld+json"
    assert_includes response.body, "Markdown version of this page is available at"
    assert_match(/rel=.alternate.*text\/markdown/i, response.headers["Link"].to_s)
  end

  test "accept negotiation returns markdown" do
    get "/", headers: { "Accept" => "text/markdown, text/html;q=0.5" }
    assert_response :success
    assert_not response.body.start_with?("<!")
    assert_includes response.headers["Vary"].to_s, "Accept"
    assert_includes response.media_type, "markdown"
  end

  test "accept negotiation returns 406 for json only" do
    get "/", headers: { "Accept" => "application/json" }
    assert_response :not_acceptable
  end

  test "accept wildcard returns html" do
    get "/", headers: { "Accept" => "*/*" }
    assert_response :success
    assert response.body.start_with?("<!DOCTYPE html>")
  end
end

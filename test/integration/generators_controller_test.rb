require "test_helper"

class GeneratorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @generator = generators(:devise)
  end

  test "renders gem installer page" do
    get generators_path(identifier: @generator.identifier)

    assert_response :success
    assert_match "Install #{@generator.name}", response.body
    assert_match @generator.invocation_command, response.body
    assert_match 'data-controller="generator-command"', response.body
  end

  test "renders guides for the gem" do
    get generators_path(identifier: @generator.identifier)

    assert_response :success
    assert_match "Guides", response.body
    assert_match "User guide", response.body
    @generator.user_guide_urls.each { |url| assert_match url, response.body }
  end

  test "returns not found for unknown identifier" do
    get generators_path(identifier: "nonexistent")

    assert_response :not_found
  end
end

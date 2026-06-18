require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "visits welcome page" do
    get root_path
    assert_response :success

    # hero section
    assert_match "Copy the command", response.body
    assert_match "Skip the setup", response.body

    # rails generator tools
    assert_match "rails generate model", response.body
    assert_match "rails generate scaffold", response.body
    assert_match "rails new", response.body

    # gem installers
    assert_match generators_path(identifier: generators(:devise).identifier), response.body
    assert_match generators_path(identifier: generators(:annotate).identifier), response.body
  end
end

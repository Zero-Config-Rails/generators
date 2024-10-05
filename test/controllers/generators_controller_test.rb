require "test_helper"

class GeneratorsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get generators_show_url
    assert_response :success
  end
end

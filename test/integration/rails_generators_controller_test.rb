require "test_helper"

class RailsGeneratorsControllerTest < ActionDispatch::IntegrationTest
  {
    "app" => ["Generate a new Rails App", "rails new"],
    "model" => ["Model Generator", "rails generate model"],
    "scaffold" => ["Scaffold Generator", "rails generate scaffold"],
    "controller" => ["Controller Generator", "rails generate controller"],
    "migration" => ["Migration Generator", "rails generate migration"],
    "resource" => ["Resource Generator", "rails generate resource"]
  }.each do |generator_id, (title, command)|
    test "show: renders #{generator_id} generator page" do
      get rails_generator_path(generator: generator_id)

      assert_response :success
      assert_match title, response.body
      assert_match command, response.body
      assert_match 'data-controller="generator-command"', response.body
    end
  end

  test "includes optional configuration toggle when options exist" do
    get rails_generator_path(generator: "model")

    assert_response :success
    assert_match "Show all configurations", response.body
    assert_match 'data-controller="visibility-toggler"', response.body
  end

  test "returns not found for unknown generator" do
    get rails_generator_path(generator: "unknown")

    assert_response :not_found
  end
end

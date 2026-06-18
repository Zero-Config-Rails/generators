require "application_system_test_case"

class RailsGeneratorsTest < ApplicationSystemTestCase
  {
    "app" => "Generate a new Rails App",
    "model" => "Model Generator",
    "scaffold" => "Scaffold Generator",
    "controller" => "Controller Generator",
    "migration" => "Migration Generator",
    "resource" => "Resource Generator"
  }.each do |generator_id, title|
    test "renders page title for #{generator_id}" do
      visit rails_generator_path(generator: generator_id)

      assert_text title
    end
  end
end

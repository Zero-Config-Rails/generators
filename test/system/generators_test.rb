require "application_system_test_case"

class GeneratorsTest < ApplicationSystemTestCase
  test "visits gem installer page" do
    visit generators_path(identifier: "devise")

    assert_text "Install Devise"
  end
end

require "application_system_test_case"

class WelcomeTest < ApplicationSystemTestCase
  test "visits landing page" do
    visit root_path

    assert_text "Zero Config Rails"
    assert_text "Copy the command"
  end
end

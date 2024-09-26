# == Schema Information
#
# Table name: dropdown_fields
#
#  id            :bigint           not null, primary key
#  default_value :string
#  options       :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class DropdownFieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

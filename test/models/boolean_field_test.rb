# == Schema Information
#
# Table name: boolean_fields
#
#  id            :bigint           not null, primary key
#  default_value :boolean
#  display_type  :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class BooleanFieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

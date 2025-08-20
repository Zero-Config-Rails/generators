# == Schema Information
#
# Table name: dropdown_fields
#
#  id            :integer          not null, primary key
#  options       :json
#  default_value :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class DropdownField < ApplicationRecord
  include Fieldable

  validates :options, presence: true
end

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
class DropdownField < ApplicationRecord
  include Fieldable

  validates :options, presence: true
end

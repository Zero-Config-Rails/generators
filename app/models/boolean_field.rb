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
class BooleanField < ApplicationRecord
  include Fieldable

  enum :display_type,
       { toggle: "toggle", checkbox: "checkbox" },
       default: "toggle",
       prefix: true,
       validate: true

  validates :default_value, inclusion: { in: [true, false] }, allow_nil: false
end

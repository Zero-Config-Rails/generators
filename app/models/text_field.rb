# == Schema Information
#
# Table name: text_fields
#
#  id            :integer          not null, primary key
#  default_value :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TextField < ApplicationRecord
  include Fieldable
end

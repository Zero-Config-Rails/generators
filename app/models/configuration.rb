# == Schema Information
#
# Table name: configurations
#
#  id                :bigint           not null, primary key
#  configuration_key :string
#  description       :string
#  fieldable_type    :string
#  is_active         :boolean          default(TRUE)
#  is_required       :boolean          default(FALSE)
#  label             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  fieldable_id      :bigint
#  generator_id      :bigint           not null
#
# Indexes
#
#  index_configurations_on_configuration_key_and_generator_id  (configuration_key,generator_id) UNIQUE
#  index_configurations_on_generator_id                        (generator_id)
#
# Foreign Keys
#
#  fk_rails_...  (generator_id => generators.id)
#
class Configuration < ApplicationRecord
  delegated_type :fieldable,
                 types: %w[BooleanField DropdownField TextField],
                 dependent: :destroy

  belongs_to :generator

  validates :configuration_key,
            presence: true,
            uniqueness: {
              scope: :generator_id
            }
  validates :fieldable, presence: true
end

# == Schema Information
#
# Table name: generators
#
#  id                 :bigint           not null, primary key
#  description        :text
#  git_url            :string
#  identifier         :string           not null
#  invocation_command :string
#  is_active          :boolean          default(TRUE)
#  logo_url           :string
#  name               :string
#  short_description  :string
#  user_guide_urls    :string           default([]), is an Array
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_generators_on_identifier  (identifier) UNIQUE
#  index_generators_on_name        (name) UNIQUE
#
class Generator < ApplicationRecord
  validates :identifier, presence: true, uniqueness: true
  validates :name, uniqueness: true, allow_nil: true
  validates :invocation_command, presence: true, uniqueness: true
  validates :user_guide_urls,
            presence: true,
            if: -> { user_guide_urls.length.positive? }

  # NOTE: is_active should be used in future to automatically sync with boring generators gem by creating a script. Script will go through generators and sync them with database, if something is added or deleted then it will notify me to approve those changes after which generator or configurations will then be activated

  has_many :configurations, dependent: :destroy

  accepts_nested_attributes_for :configurations, allow_destroy: :true
end

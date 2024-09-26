# == Schema Information
#
# Table name: generators
#
#  id                 :bigint           not null, primary key
#  description        :text
#  git_url            :string
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
#  index_generators_on_name  (name) UNIQUE
#
require "test_helper"

class GeneratorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

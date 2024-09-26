module Fieldable
  extend ActiveSupport::Concern

  included { has_one :configuration, as: :fieldable, touch: true }
end

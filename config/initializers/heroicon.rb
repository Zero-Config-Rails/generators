# frozen_string_literal: true

Heroicon.configure do |config|
  config.variant = :outline # Options are :solid, :outline and :mini

  config.default_class = {
    solid: "size-5",
    outline: "size-5",
    mini: "size-3"
  }
end

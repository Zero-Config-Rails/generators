class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # TODO: find a way to show warning page to users with the option to access the page instead of complete restrictions
  # allow_browser versions: :modern
end

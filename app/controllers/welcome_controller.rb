class WelcomeController < ApplicationController
  def index
    @generators_dropdown = Generator.search_dropdown
  end
end

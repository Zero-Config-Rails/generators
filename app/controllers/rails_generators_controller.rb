class RailsGeneratorsController < ApplicationController
  def show
    @generator_id = params[:generator]

    head :not_found unless helpers.rails_generator_valid?(@generator_id)
  end
end

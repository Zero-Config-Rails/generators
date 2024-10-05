class GeneratorsController < ApplicationController
  before_action :set_generator

  def show
  end

  private

  def set_generator
    @generator = Generator.find_by!(identifier: params[:identifier])
  end
end

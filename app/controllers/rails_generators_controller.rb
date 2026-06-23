class RailsGeneratorsController < ApplicationController
  include SeoDiscoverable

  def show
    @generator_id = params[:generator]

    unless helpers.rails_generator_valid?(@generator_id)
      head :not_found
      return
    end

    respond_to do |format|
      format.html
      format.md { render_seo_markdown }
    end
  end

  private

  def seo_html_path
    "/rails_generators/#{params[:generator]}"
  end
end

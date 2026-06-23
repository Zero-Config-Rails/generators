class GeneratorsController < ApplicationController
  include SeoDiscoverable

  before_action :set_generator

  def show
    respond_to do |format|
      format.html
      format.md { render_seo_markdown }
    end
  end

  private

  def set_generator
    @generator = Generator.find_by!(identifier: params[:identifier])
  end

  def seo_html_path
    "/install/#{params[:identifier]}"
  end
end

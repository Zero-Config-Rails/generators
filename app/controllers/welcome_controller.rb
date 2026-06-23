class WelcomeController < ApplicationController
  include SeoDiscoverable

  def index
    respond_to do |format|
      format.html
      format.md { render_seo_markdown }
    end
  end

  private

  def seo_html_path
    "/"
  end
end

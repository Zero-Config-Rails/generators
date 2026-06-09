module NavigationHelper
  include Rails.application.routes.url_helpers

  ZCR_SITE_URL = "https://zeroconfigrails.com"
  # ZCR_APP_URL = "https://app.zeroconfigrails.com"
  # TODO: For now, just redirect to the site URL. Once we release the app, we can use the app URL.
  ZCR_APP_URL = "https://zeroconfigrails.com"
  ZCR_TAGLINE = "The multi-flavor SaaS starter kit for modern Rails teams"

  def rails_app_generator_tool
    {
      name: "Rails App Generator",
      description: "Build a rails new command with the right flags — no man page archaeology.",
      path: app_rails_generators_path,
      command: "rails new"
    }
  end

  def gem_installer_tools
    Generator.active.order(Arel.sql("COALESCE(name, identifier)")).map do |generator|
      {
        name: generator.name || generator.identifier.humanize.titleize,
        description: generator.short_description.presence || generator.description,
        path: generators_path(identifier: generator.identifier),
        command: "zen add #{generator.invocation_command}"
      }
    end
  end

  def all_tools
    [rails_app_generator_tool] + gem_installer_tools
  end
end

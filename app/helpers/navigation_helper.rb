module NavigationHelper
  include Rails.application.routes.url_helpers

  ZCR_SITE_URL = "https://zeroconfigrails.com"
  ZCR_APP_URL = "https://app.zeroconfigrails.com"
  ZCR_TAGLINE = "The multi-flavor SaaS starter kit for modern Rails teams"

  def rails_generator_tools
    RailsGenerators::ConfigurationsHelper::GENERATOR_IDS.map do |id|
      meta =
        if id == "app"
          RailsGenerators::ConfigurationsHelper::APP_META
        else
          RailsGenerate::Registry.meta(id)
        end

      {
        name: id == "app" ? meta["tool_name"] : "#{meta['title']} Generator",
        description: meta["description"],
        path: rails_generator_path(generator: id),
        command: meta["command"]
      }
    end
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
    rails_generator_tools + gem_installer_tools
  end
end

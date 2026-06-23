module SeoDiscoverability
  module Site
    URL = ENV.fetch("SITE_URL", "https://generators.zeroconfigrails.com").freeze
    NAME = "Zero Config Rails Generators".freeze
    DESCRIPTION =
      "Free interactive tools for Rails teams - configure rails new, install gems with a single command, and skip the setup sprint. From the makers of Zero Config Rails.".freeze
    TAGLINE = "Copy the command. Skip the setup.".freeze

    module_function

    def absolute(path)
      path = "/#{path}" unless path.start_with?("/")
      "#{URL}#{path}"
    end
  end
end

module SeoDiscoverability
  module Site
    URL = ENV.fetch("SITE_URL", "https://generators.zeroconfigrails.com").freeze
    NAME = "Zero Config Rails Tools".freeze
    DESCRIPTION =
      "Free interactive tools for Rails developers: configure rails new, tune generator flags, and install gems with a single command. From the makers of Zero Config Rails.".freeze
    TAGLINE = "Copy the command. Skip the setup.".freeze

    module_function

    def absolute(path)
      path = "/#{path}" unless path.start_with?("/")
      "#{URL}#{path}"
    end
  end
end

namespace :generator do
  task seed: :environment do
    existing_generators = Generator.pluck(:identifier)

    generators = [
      {
        identifier: "annotate",
        description: "Annotate Rails classes with schema and routes info",
        git_url: "https://github.com/ctran/annotate_models",
        invocation_command: "annotate",
        configurations_attributes: [
          {
            configuration_key: "skip_on_db_migrate",
            description:
              "Mark true if you don't want to annotate models after each `rails db:migrate`. You will have to annotate models manually by running a rake task in that case.",
            is_required: false,
            fieldable: BooleanField.new(default_value: false)
          }
        ]
      },
      {
        identifier: "avo",
        description:
          "Beautiful next-generation framework that empowers you, the developer, to create fantastic admin panels for your Ruby on Rails apps with the flexibility to fit your needs as you grow.",
        short_description:
          "Admin Panel Framework, Content Management System, and Internal Tool Builder",
        git_url: "https://github.com/avo-hq/avo",
        logo_url: "https://avatars.githubusercontent.com/u/66615189?s=48&v=4",
        user_guide_urls: ["https://docs.avohq.io/3.0/installation.html"],
        invocation_command: "avo"
      },
      {
        identifier: "devise",
        description: "Flexible authentication solution for Rails with Warden",
        git_url: "https://github.com/heartcombo/devise",
        user_guide_urls: [
          "https://github.com/heartcombo/devise?tab=readme-ov-file#getting-started"
        ],
        invocation_command: "devise",
        configurations_attributes: [
          {
            configuration_key: "model_name",
            description: "Model used for authentication. Defaults to User",
            is_required: true,
            fieldable: TextField.new(default_value: "User")
          },
          {
            configuration_key: "skip_devise_view",
            description: "Skip generating Devise views",
            is_required: false,
            fieldable: BooleanField.new(default_value: false)
          },
          {
            configuration_key: "skip_devise_model",
            description: "Skip generating Devise model",
            is_required: false,
            fieldable: BooleanField.new(default_value: false)
          },
          {
            configuration_key: "run_db_migrate",
            description: "Run pending migrations",
            is_required: false,
            fieldable: BooleanField.new(default_value: false)
          }
        ]
      },
      {
        identifier: "dotenv",
        description: "Ruby gem to load environment variables from `.env`",
        git_url: "https://github.com/bkeepers/dotenv",
        invocation_command: "dotenv"
      },
      {
        identifier: "figjam",
        description: "ENV configuration for Ruby using YAML files",
        git_url: "https://github.com/hlascelles/figjam",
        logo_url: "https://github.com/hlascelles/figjam/blob/master/jamjar.png",
        invocation_command: "figjam"
      },
      {
        identifier: "honeybadger",
        name: "Honey Badger",
        description:
          "Application health monitoring tool built by developers for developers",
        git_url:
          "https://github.com/honeybadger-io/honeybadger-ruby/tree/master",
        user_guide_urls: [
          "https://docs.honeybadger.io/lib/ruby/getting-started/introduction"
        ],
        logo_url: "https://avatars.githubusercontent.com/u/1898541",
        invocation_command: "honeybadger",
        configurations_attributes: [
          {
            configuration_key: "use_env_variable",
            description:
              "Use ENV variable for API Key. By default Rails credentials will be used.",
            is_required: false,
            fieldable: BooleanField.new(default_value: false)
          }
        ]
      },
      {
        identifier: "letter_opener",
        description:
          "Preview mail in the browser instead of sending it to the real mailbox",
        git_url: "https://github.com/ryanb/letter_opener",
        user_guide_urls: [
          "https://github.com/ryanb/letter_opener?tab=readme-ov-file#rails-setup"
        ],
        invocation_command: "letter_opener"
      },
      {
        identifier: "overcommit-rubocop",
        name: "Overcommit for RuboCop",
        description: "Fully configurable and extendable Git hook manager",
        git_url: "https://github.com/sds/overcommit",
        user_guide_urls: [
          "https://github.com/sds/overcommit?tab=readme-ov-file#installation"
        ],
        invocation_command: "overcommit:pre_commit:rubocop",
        configurations_attributes: [
          {
            configuration_key: "skip_configuration",
            description: "Skip configuring overcommit in your local machine",
            is_required: false,
            fieldable: BooleanField.new(default_value: false)
          }
        ]
      },
      # {
      #   # NOTE: can't add right now because this requires multi-select dropdown for skipping extension
      #   identifier: "pronto-github_action",
      #   name: "Pronto (for Github Action)",
      #   description: "Quick automated code review of your changes",
      #   git_url: "https://github.com/prontolabs/pronto",
      #   logo_url: "https://avatars.githubusercontent.com/u/28510538?s=48&v=4",
      #   user_guide_urls: [
      #     "https://github.com/prontolabs/pronto?tab=readme-ov-file#github-integration"
      #   ],
      #   invocation_command: "pronto:github_action",
      #   configurations_attributes: [
      #     {
      #       configuration_key: "ruby_version",
      #       description:
      #         "Ruby version used by your app. Defaults to .ruby_version or the version specified in your Gemfile.",
      #       is_required: false,
      #       fieldable: TextField.new
      #     },
      #     {
      #       configuration_key: "skip_extensions",
      #       description: "List of extensions to skip",
      #       is_required: false,
      #       fieldable:
      #         MultiSelectDropdownField.new(
      #           options: {
      #             brakeman: nil,
      #             flay: nil,
      #             reek: nil,
      #             rubocop: nil
      #           },
      #           default_value: []
      #         )
      #     }
      #   ]
      # },
      # {
      #   # NOTE: can't add right now because this requires multi-select dropdown for skipping extension
      #   identifier: "pronto-gitlab_ci",
      #   name: "Pronto (for Gitlab CI)",
      #   description: "Quick automated code review of your changes",
      #   git_url: "https://github.com/prontolabs/pronto",
      #   logo_url: "https://avatars.githubusercontent.com/u/28510538?s=48&v=4",
      #   user_guide_urls: %w[
      #     https://prabinpoudel.com.np/articles/integrate-pronto-with-gitlab-ci-for-rails-app/
      #     https://github.com/prontolabs/pronto?tab=readme-ov-file#gitlab-integration
      #   ],
      #   invocation_command: "pronto:gitlab_ci",
      #   configurations_attributes: [
      #     {
      #       configuration_key: "ruby_version",
      #       description:
      #         "Ruby version used by your app. Defaults to .ruby_version or the version specified in your Gemfile.",
      #       is_required: false,
      #       fieldable: TextField.new
      #     },
      #     {
      #       configuration_key: "skip_extensions",
      #       description: "List of extensions to skip",
      #       is_required: false,
      #       fieldable:
      #         MultiSelectDropdownField.new(
      #           options: {
      #             brakeman: nil,
      #             flay: nil,
      #             reek: nil,
      #             rubocop: nil
      #           },
      #           default_value: []
      #         )
      #     }
      #   ]
      # },
      {
        identifier: "rails-erd",
        name: "Rails ERD",
        description:
          "Generate Entity-Relationship Diagrams for Rails applications",
        git_url: "https://github.com/voormedia/rails-erd",
        invocation_command: "rails_erd"
      },
      {
        identifier: "rspec",
        name: "RSpec Rails",
        description:
          "Rails Test Framework. Behaviour Driven Development for Ruby",
        git_url: "https://github.com/rspec/rspec-rails",
        user_guide_urls: [
          "https://github.com/rspec/rspec-rails?tab=readme-ov-file#installation"
        ],
        logo_url: "https://rspec.info/images/logo.png",
        invocation_command: "rspec",
        configurations_attributes: [
          {
            configuration_key: "skip_factory_bot",
            description: "Skip installing Factory Bot",
            is_required: true,
            fieldable: BooleanField.new(default_value: false)
          },
          {
            configuration_key: "skip_faker",
            description: "Skip installing Faker gem",
            is_required: false,
            fieldable: BooleanField.new(default_value: true)
          }
        ]
      },
      # {
      #   # Note: can't add right now because breadcrumbs logger uses tag field that is not yet implemented
      #   identifier: "sentry",
      #   description: "Error Tracking and Performance Monitoring",
      #   git_url: "https://github.com/getsentry/sentry-ruby",
      #   user_guide_urls: ["https://docs.sentry.io/platforms/ruby/guides/rails"],
      #   logo_url: "https://avatars.githubusercontent.com/u/1396951",
      #   invocation_command: "sentry",
      #   configurations_attributes: [
      #     {
      #       configuration_key: "use_env_variable",
      #       description:
      #         "Use ENV variable for DSN Key. By default Rails credentials will be used.",
      #       is_required: false,
      #       fieldable: BooleanField.new(default_value: false)
      #     },
      #     {
      #       configuration_key: "breadcrumbs_logger",
      #       description:
      #         "Set the breadcrumbs logger. By default [:active_support_logger, :http_logger] will be used.",
      #       is_required: false,
      #       fieldable:
      #         TagField.new(default_value: %i[active_support_logger http_logger])
      #     }
      #   ]
      # },
      # {
      #   # NOTE: can't add right now because this requires multi-select dropdown for skipping extension
      #   identifier: "vcr",
      #   name: "VCR",
      #   description:
      #     "Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests",
      #   git_url: "https://github.com/vcr/vcr",
      #   logo_url: "https://avatars.githubusercontent.com/u/2902977?s=48&v=4",
      #   user_guide_urls: ["https://benoittgt.github.io/vcr/#/"],
      #   invocation_command: "vcr",
      #   configurations_attributes: [
      #     {
      #       configuration_key: "testing_framework",
      #       label: "Test framework",
      #       description: "Framework you use for testing. Defaults to Minitest.",
      #       is_required: true,
      #       fieldable:
      #         DropdownField.new(
      #           options: {
      #             minitest: nil,
      #             rspec: "RSpec"
      #           },
      #           default_value: "minitest"
      #         )
      #     },
      #     {
      #       configuration_key: "stubbing_libraries",
      #       description:
      #         "Gem you use for managing environment variables. Defaults to Rails Credentials",
      #       is_required: true,
      #       fieldable:
      #         MultiSelectDropdownField.new(
      #           options: {
      #             webmock: nil,
      #             typhoeus: nil,
      #             faraday: nil,
      #             excon: nil
      #           },
      #           default_value: ["webmock"]
      #         )
      #     }
      #   ]
      # },
      {
        identifier: "webmock",
        description:
          "Library for stubbing and setting expectations on HTTP requests in Ruby",
        short_description:
          "Admin Panel Framework, Content Management System, and Internal Tool Builder",
        git_url: "https://github.com/bblimke/webmock",
        user_guide_urls: [
          "https://github.com/bblimke/webmock?tab=readme-ov-file#installation"
        ],
        invocation_command: "webmock",
        configurations_attributes: [
          {
            configuration_key: "app_test_framework",
            label: "Test framework",
            description: "Framework you use for testing. Defaults to Minitest.",
            is_required: true,
            fieldable:
              DropdownField.new(
                options: {
                  minitest: nil,
                  rspec: "RSpec"
                },
                default_value: "minitest"
              )
          }
        ]
      },
      {
        identifier: "whenever",
        description: "Cron jobs in Ruby",
        git_url: "https://github.com/javan/whenever",
        user_guide_urls: [
          "https://github.com/javan/whenever?tab=readme-ov-file#installation"
        ],
        invocation_command: "whenever"
      }
    ]

    new_generators =
      generators
        .map do |generator|
          next if existing_generators.include?(generator[:identifier])

          generator
        end
        .compact

    Generator.create!(new_generators)
  end
end

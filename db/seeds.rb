# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Generator.create!(
  identifier: "gitlab_ci",
  name: "Gitlab CI",
  description: "Setup Gitlab CI",
  user_guide_urls: %w[
    https://blog.zeroconfigrails.com/configure-minitest-with-gitlab-ci-and-rails
    https://blog.zeroconfigrails.com/setup-and-run-rspec-tests-with-gitlab-ci
  ],
  invocation_command: "ci:gitlab_ci",
  configurations_attributes: [
    {
      configuration_key: "ruby_version",
      description:
        "Ruby version used by your app. Defaults to .ruby_version or the version specified in your Gemfile.",
      is_required: false,
      fieldable: TextField.new
    },
    {
      configuration_key: "database",
      description: "Database used in your app",
      is_required: true,
      fieldable:
        DropdownField.new(
          options: {
            sqlite3: "SQLite",
            postgresql: "PostgreSQL",
            mysql: "MySQL"
          },
          default_value: "sqlite3"
        )
    },
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
    },
    {
      configuration_key: "environment_variable_manager",
      description:
        "Gem you use for managing environment variables. Defaults to Rails Credentials",
      is_required: true,
      fieldable:
        DropdownField.new(
          options: {
            rails_credentials: nil,
            dotenv: nil,
            figjam: "Figjam (Maintained fork of Figaro)"
          },
          default_value: "rails_credentials"
        )
    },
    {
      configuration_key: "skip_sample_tests",
      description:
        "By default sample tests are added to your app when configuring this generator to make it easy to verify if CI is working correctly. You can skip it if you are setting this up in an existing project that already has tests",
      is_required: false,
      fieldable: BooleanField.new(default_value: false)
    }
  ]
)

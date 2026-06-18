require "test_helper"
require "rails_generate/help_parser"

class RailsGenerate::HelpParserTest < ActiveSupport::TestCase
  MODEL_HELP = <<~HELP.freeze
    Usage:
      bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

    Options:
          [--skip-namespace]                                            # Skip namespace
                                                                          # Default: false
          [--api], [--no-api], [--skip-api]                             # API only
                                                                          # Default: false

    ActiveRecord options:
            [--migration], [--no-migration], [--skip-migration]         # Generate migration
                                                                          # Default: true
            [--parent=PARENT]                                           # Parent class
                                                                          # Default: ApplicationRecord
  HELP

  test "extracts option keys" do
    keys = RailsGenerate::HelpParser.new(MODEL_HELP).option_keys

    assert_includes keys, "skip-namespace"
    assert_includes keys, "api"
    assert_includes keys, "migration"
    assert_includes keys, "parent"
  end

  test "detects flag formats" do
    configs = RailsGenerate::HelpParser.new(MODEL_HELP).parse_configurations
    api = configs.find { |c| c[:configuration_key] == "api" }
    migration = configs.find { |c| c[:configuration_key] == "migration" }
    parent = configs.find { |c| c[:configuration_key] == "parent" }

    assert_equal "positive_boolean", api[:flag_format]
    assert_equal "negative_boolean", migration[:flag_format]
    assert_equal "skip", migration[:negative_prefix]
    assert_equal "value", parent[:flag_format]
  end

  test "filters gem injected options" do
    help = MODEL_HELP + "      [--avo-resource]  # Avo resource\n"
    keys = RailsGenerate::HelpParser.new(help).option_keys

    assert_not_includes keys, "avo-resource"
  end
end

namespace :rails_new do
  desc "Parse rails new --help output and generate configurations"
  task parse_options: :environment do
    help = RailsGenerate::VanillaRailsApp.rails_new_help
    configurations = RailsGenerate::HelpParser.new(help).parse_configurations
    RailsGenerate::RailsNewConfigurationWriter.new(configurations: configurations).write!
  end
end

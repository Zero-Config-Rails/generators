namespace :rails_generate do
  desc "Parse rails generate GENERATOR --help and generate configuration helpers"
  task :parse, [:generator] => :environment do |_task, args|
    generator = args[:generator]
    abort "Usage: rake rails_generate:parse[model]" if generator.blank?
    abort "Unknown generator: #{generator}" unless RailsGenerate::Registry.all_ids.include?(generator)

  meta = RailsGenerate::Registry.meta(generator)
  help = RailsGenerate::VanillaRailsApp.generate_help(generator)
  configurations = RailsGenerate::HelpParser.new(help).parse_configurations

  RailsGenerate::ConfigurationWriter.new(
    generator_id: generator,
    configurations: configurations,
    command: meta["command"]
  ).write!
  end

  desc "Parse all in-scope rails generate helpers"
  task parse_all: :environment do
    RailsGenerate::VanillaRailsApp.with_app do |app_dir|
      RailsGenerate::Registry.all_ids.each do |generator|
        meta = RailsGenerate::Registry.meta(generator)
        help = RailsGenerate::VanillaRailsApp.generate_help_in_app(app_dir, generator)
        configurations = RailsGenerate::HelpParser.new(help).parse_configurations

        RailsGenerate::ConfigurationWriter.new(
          generator_id: generator,
          configurations: configurations,
          command: meta["command"]
        ).write!
      end
    end
  end
end

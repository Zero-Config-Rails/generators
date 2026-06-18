namespace :rails_options do
  desc "Capture current vanilla Rails generator options into baseline YAML"
  task baseline: :environment do
    RailsGenerate::OptionsSnapshot.write_baseline!
  end

  desc "Check for drift between baseline and current vanilla Rails generator options"
  task check: :environment do
    success = RailsGenerate::OptionsSnapshot.check!

    exit(1) unless success
  end
end

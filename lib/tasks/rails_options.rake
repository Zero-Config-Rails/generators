namespace :rails_options do
  desc "Capture generator options from the app's Rails version into baseline YAML"
  task baseline: :environment do
    RailsGenerate::OptionsSnapshot.write_baseline!
  end

  desc "Compare current Rails generator options against the committed baseline"
  task check: :environment do
    success = RailsGenerate::OptionsSnapshot.check!

    exit(1) unless success
  end
end

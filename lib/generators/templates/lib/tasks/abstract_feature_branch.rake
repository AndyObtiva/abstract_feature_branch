require 'abstract_feature_branch'
namespace :abstract_feature_branch do

  desc "Beautify YAML of specified feature file via file_path argument or all feature files when no argument specified (config/features.yml, config/features.local.yml, and config/features/**/*.yml) by sorting features by name and eliminating extra empty lines"
  task :beautify_files, :file_path do |_, args|
    AbstractFeatureBranch::FileBeautifier.process(args[:file_path])
  end

end
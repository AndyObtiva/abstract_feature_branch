module AbstractFeatureBranch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates Abstract Feature Branch configuration files in your application."
      def copy_config
        template "config/features.yml", "config/features.yml"
        template "config/features.local.yml", "config/features.local.yml"
        append_to_file '.gitignore', <<-GIT_IGNORE_CONTENT

#abstract_feature_branch local configuration file
config/features.local.yml
        GIT_IGNORE_CONTENT
      end
    end
  end
end

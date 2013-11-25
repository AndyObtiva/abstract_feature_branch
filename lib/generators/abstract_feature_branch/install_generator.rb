module AbstractFeatureBranch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs Abstract Feature Branch by generating basic configuration files, including git ignored local one."
      def copy_config
        template "lib/tasks/abstract_feature_branch.rake", "lib/tasks/abstract_feature_branch.rake"
        template "config/initializers/abstract_feature_branch.rb", "config/initializers/abstract_feature_branch.rb"
        template "config/features.example.yml", "config/features.yml"
        template "config/features.local.yml", "config/features.local.yml"
        append_to_file '.gitignore', <<-GIT_IGNORE_CONTENT

#abstract_feature_branch local configuration file
/config/features.local.yml
/config/features/*.local.yml
/config/features/**/*.local.yml
        GIT_IGNORE_CONTENT
      end
    end
  end
end

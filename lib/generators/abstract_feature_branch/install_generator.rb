module AbstractFeatureBranch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates an Abstract Feature Branch configuration file in your application."

      def copy_config
        template "config/features.yml", "config/features.yml"
      end
    end
  end
end

module AbstractFeatureBranch
  module Generators
    class ContextGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a configuration file for a specific application context (e.g. admin). Takes context path as argument (e.g. admin or internal/wiki) to create config/features/#{file_path}.yml"
      def copy_config
        template "config/features.yml", "config/features/#{file_path}.yml"
      end
    end
  end
end

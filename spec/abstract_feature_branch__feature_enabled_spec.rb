require 'spec_helper'

describe 'abstract_feature_branch' do
  before do
    @app_env_backup = AbstractFeatureBranch.application_environment
    puts 'Environment variable ABSTRACT_FEATURE_BRANCH_FEATURE1 already set, potentially conflicting with another test' if ENV.keys.include?('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    puts 'Environment variable Abstract_Feature_Branch_Feature2 already set, potentially conflicting with another test' if ENV.keys.include?('Abstract_Feature_Branch_Feature2')
    puts 'Environment variable abstract_feature_branch_feature3 already set, potentially conflicting with another test' if ENV.keys.include?('abstract_feature_branch_feature3')
  end
  after do
    ENV.delete('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    ENV.delete('Abstract_Feature_Branch_Feature2')
    ENV.delete('abstract_feature_branch_feature3')
    AbstractFeatureBranch.initialize_application_root
    AbstractFeatureBranch.load_application_features
    AbstractFeatureBranch.application_environment = @app_env_backup
  end
  describe 'feature_enabled?' do
    it 'determines whether a feature is enabled or not in features configuration (case-insensitive string or symbol feature names)' do
      feature_enabled?('Feature1').should == true
      feature_enabled?(:FEATURE2).should == true
      feature_enabled?(:feature3).should == false
    end
    it 'returns nil for an invalid feature name' do
      feature_enabled?(:invalid_feature_that_does_not_exist).should be_nil
    end
    it 'allows environment variables (case-insensitive booleans) to override configuration file' do
      ENV['ABSTRACT_FEATURE_BRANCH_FEATURE1'] = 'FALSE'
      ENV['Abstract_Feature_Branch_Feature2'] = 'False'
      ENV['abstract_feature_branch_feature3'] = 'true'
      AbstractFeatureBranch.load_application_features
      feature_enabled?(:feature1).should == false
      feature_enabled?(:feature2).should == false
      feature_enabled?(:feature3).should == true
      feature_enabled?(:feature4a).should == true #not overridden
    end
    it 'allows local configuration file to override main configuration file in test environment' do
      feature_enabled?(:feature4).should == false
      feature_enabled?(:feature5).should == true
    end
    it 'no local configuration in production environment' do
      AbstractFeatureBranch.application_environment = 'production'
      feature_enabled?(:feature4).should == true
      feature_enabled?(:feature5).should be_nil
    end
    it 'works with Rails environment' do
      Object.class_eval do
        module Rails
          def self.root
            File.expand_path(File.join(__FILE__, '..', 'application_rails_config'))
          end
          def self.env
            'staging'
          end
        end
      end
      AbstractFeatureBranch.initialize_application_root
      AbstractFeatureBranch.initialize_application_environment
      AbstractFeatureBranch.load_application_features
      feature_enabled?(:feature1).should == true
      feature_enabled?(:feature2).should == false
      feature_enabled?(:feature3).should == false
      feature_enabled?(:feature4).should be_nil
      feature_enabled?(:feature4a).should be_nil
      feature_enabled?(:feature5).should be_nil
    end
  end
  describe 'self#feature_enabled?' do
    after do
      Object.send(:remove_const, :TestObject)
    end
    # No need to retest all instance test cases, just a spot check due to implementation reuse
    it 'determines whether a feature is enabled or not in features configuration' do
      class TestObject
        def self.hit_me
          feature_enabled?(:feature1).should == true
          feature_enabled?(:feature2).should == true
          feature_enabled?(:feature3).should == false
        end
      end
      TestObject.hit_me
    end
  end
end

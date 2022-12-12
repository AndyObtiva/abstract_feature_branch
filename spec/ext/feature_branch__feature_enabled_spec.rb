require 'spec_helper'

describe 'feature_branch object extensions' do
  before do
    @app_env_backup = AbstractFeatureBranch.application_environment
    @app_root_backup = AbstractFeatureBranch.application_root
    AbstractFeatureBranch.logger.warn 'Environment variable ABSTRACT_FEATURE_BRANCH_FEATURE1 already set, potentially conflicting with another test' if ENV.keys.include?('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    AbstractFeatureBranch.logger.warn 'Environment variable Abstract_Feature_Branch_Feature2 already set, potentially conflicting with another test' if ENV.keys.include?('Abstract_Feature_Branch_Feature2')
    AbstractFeatureBranch.logger.warn 'Environment variable abstract_feature_branch_feature3 already set, potentially conflicting with another test' if ENV.keys.include?('abstract_feature_branch_feature3')
  end
  after do
    ENV.delete('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    ENV.delete('Abstract_Feature_Branch_Feature2')
    ENV.delete('abstract_feature_branch_feature3')
    AbstractFeatureBranch.application_root = @app_root_backup
    AbstractFeatureBranch.application_environment = @app_env_backup
    AbstractFeatureBranch.unload_application_features
    AbstractFeatureBranch.feature_store.keys.each do |key|
      AbstractFeatureBranch.feature_store.del(key)
    end
    AbstractFeatureBranch.configuration.feature_store_live_fetching = nil # reset to default
  end
  describe '#feature_enabled?' do
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

    it 'allows redis variables (case-insensitive booleans) to override configuration file, not live' do
      AbstractFeatureBranch.unload_application_features
      AbstractFeatureBranch.load_application_features
      
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'FEATURE1', 'FALSE')
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'Feature2', 'False')
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'feature3', 'true')
      
      # before reloading features after store feature changes
      feature_enabled?('Feature1').should == true
      feature_enabled?(:FEATURE2).should == true
      feature_enabled?(:feature3).should == false
      feature_enabled?(:feature4a).should == true #not overridden
      
      AbstractFeatureBranch.unload_application_features
      AbstractFeatureBranch.load_application_features
      # after reloading features after store feature changes
      feature_enabled?(:feature1).should == false
      feature_enabled?(:feature2).should == false
      feature_enabled?(:feature3).should == true
      feature_enabled?(:feature4a).should == true #not overridden
    end
    
    it 'allows redis variables (case-insensitive booleans) to override configuration file, live' do
      AbstractFeatureBranch.configuration.feature_store_live_fetching = true
      AbstractFeatureBranch.unload_application_features
      AbstractFeatureBranch.load_application_features
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'FEATURE1', 'FALSE')
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'Feature2', 'False')
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'feature3', 'true')
      feature_enabled?(:feature1).should == false
      feature_enabled?(:feature2).should == false
      feature_enabled?(:feature3).should == true
      feature_enabled?(:feature4a).should == true #not overridden
    end
    
    it 'allows redis variables (case-insensitive booleans) to override configuration file via a ConnectionPool instance' do
      AbstractFeatureBranch.unload_application_features
      AbstractFeatureBranch.feature_store = ConnectionPool.new { Redis.new }
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'FEATURE1', 'FALSE')
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'Feature2', 'False')
      AbstractFeatureBranch.feature_store.hset('abstract_feature_branch', 'feature3', 'true')
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
    it 'has no local configuration for production environment' do
      AbstractFeatureBranch.application_environment = 'production'
      feature_enabled?(:feature4).should == true
      feature_enabled?(:feature5).should be_nil
    end
    it 'works with Rails environment' do
      Object.class_eval do
        module Rails
          def self.root
            File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_rails_config'))
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
    context 'per user' do
      let(:user_id) { 'email1@example.com' }
      let(:another_user_id) { 'another_email@example.com' }
      before do
        AbstractFeatureBranch.user_features_storage.del("#{AbstractFeatureBranch::ENV_FEATURE_PREFIX}feature6")
      end
      after do
        AbstractFeatureBranch.user_features_storage.del("#{AbstractFeatureBranch::ENV_FEATURE_PREFIX}feature6")
      end
      it 'behaves as expected if member list is empty, regardless of the user provided' do
        feature_enabled?('feature6').should == false
        feature_enabled?('feature6', nil).should == false
        feature_enabled?('feature6', user_id).should == false
      end
      it 'behaves as expected if member list is not empty, and user provided is in member list' do
        AbstractFeatureBranch.toggle_features_for_user(user_id, :feature6 => true)
        feature_enabled?('feature6').should == false
        feature_enabled?('feature6', user_id).should == true
      end
      it 'behaves as expected if member list is not empty, and user provided is not in member list' do
        AbstractFeatureBranch.toggle_features_for_user(another_user_id, :feature6 => true)
        feature_enabled?('feature6', user_id).should == false
      end
    end
    context 'cacheability' do
      before do
        @development_application_root = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_development_config'))
        @feature_file_reference_path = File.join(@development_application_root, 'config', 'features.reference.yml')
        @feature_file_path = File.join(@development_application_root, 'config', 'features.yml')
        FileUtils.cp(@feature_file_reference_path, @feature_file_path)
        AbstractFeatureBranch.application_root = @development_application_root
      end
      after do
        FileUtils.rm(@feature_file_path)
      end
      it 'refreshes features at runtime in development (without forcing load of application features again)' do
        AbstractFeatureBranch.application_environment = 'development'
        feature_enabled?(:feature1).should == false
        feature_enabled?(:feature2).should == true
        File.open(@feature_file_path, 'w+') do |file|
          file << <<-CONTENT
defaults: &defaults

development:
  <<: *defaults
  FEATURE1: true
  Feature2: false

test:
  <<: *defaults
  FEATURE1: true
  Feature2: false

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: false

production:
  <<: *defaults
  FEATURE1: true
  Feature2: false
          CONTENT
        end
        feature_enabled?(:feature1).should == true
        feature_enabled?(:feature2).should == false
      end

      %w(test staging production).each do |environment|
        it "does not refresh features at runtime in #{environment} (without forcing load of application features again)" do
          AbstractFeatureBranch.application_environment = environment
          AbstractFeatureBranch.load_application_features
          feature_enabled?(:feature1).should == false
          feature_enabled?(:feature2).should == true
          File.open(@feature_file_path, 'w+') do |file|
            file << <<-CONTENT
defaults: &defaults

development:
  <<: *defaults
  FEATURE1: true
  Feature2: false

test:
  <<: *defaults
  FEATURE1: true
  Feature2: false

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: false

production:
  <<: *defaults
  FEATURE1: true
  Feature2: false
            CONTENT
          end
          feature_enabled?(:feature1).should == false
          feature_enabled?(:feature2).should == true
        end
      end

      it 'does not refresh features at runtime in development when overridden' do
        AbstractFeatureBranch.application_environment = 'development'
        AbstractFeatureBranch.cacheable = {:development => true}
        AbstractFeatureBranch.load_application_features
        feature_enabled?(:feature1).should == false
        feature_enabled?(:feature2).should == true
        File.open(@feature_file_path, 'w+') do |file|
          file << <<-CONTENT
defaults: &defaults

development:
  <<: *defaults
  FEATURE1: true
  Feature2: false

test:
  <<: *defaults
  FEATURE1: true
  Feature2: false

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: false

production:
  <<: *defaults
  FEATURE1: true
  Feature2: false
            CONTENT
          end
        feature_enabled?(:feature1).should == false
        feature_enabled?(:feature2).should == true
      end

      %w(test staging production).each do |environment|
        it "does refresh features at runtime in #{environment} (without forcing load of application features again)" do
          AbstractFeatureBranch.application_environment = environment
          AbstractFeatureBranch.cacheable = {:test => false, :staging => false, :production => false}
          feature_enabled?(:feature1).should == false
          feature_enabled?(:feature2).should == true
          File.open(@feature_file_path, 'w+') do |file|
            file << <<-CONTENT
defaults: &defaults

development:
  <<: *defaults
  FEATURE1: true
  Feature2: false

test:
  <<: *defaults
  FEATURE1: true
  Feature2: false

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: false

production:
  <<: *defaults
  FEATURE1: true
  Feature2: false
            CONTENT
          end
          feature_enabled?(:feature1).should == true
          feature_enabled?(:feature2).should == false
        end
      end
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

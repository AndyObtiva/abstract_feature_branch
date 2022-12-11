require 'spec_helper'

describe 'feature_branch object extensions' do
  before do
    @app_env_backup = AbstractFeatureBranch.application_environment
    @app_root_backup = AbstractFeatureBranch.application_root
    AbstractFeatureBranch.logger.warn 'Environment variable ABSTRACT_FEATURE_BRANCH_FEATURE1 already set, potentially conflicting with another test' if ENV.keys.include?('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    AbstractFeatureBranch.logger.warn 'Environment variable Abstract_Feature_Branch_Feature2 already set, potentially conflicting with another test' if ENV.keys.include?('Abstract_Feature_Branch_Feature2')
    AbstractFeatureBranch.logger.warn 'Environment variable abstract_feature_branch_feature3 already set, potentially conflicting with another test' if ENV.keys.include?('abstract_feature_branch_feature3')
    begin
      AbstractFeatureBranch.user_features_storage.flushall
    rescue => e
      #noop
    end
  end
  after do
    ENV.delete('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    ENV.delete('Abstract_Feature_Branch_Feature2')
    ENV.delete('abstract_feature_branch_feature3')
    AbstractFeatureBranch.application_root = @app_root_backup
    AbstractFeatureBranch.application_environment = @app_env_backup
    AbstractFeatureBranch.unload_application_features
    begin
      AbstractFeatureBranch.user_features_storage.flushall
    rescue => e
    #noop
    end
    AbstractFeatureBranch.user_features_storage.keys.each do |key|
      AbstractFeatureBranch.user_features_storage.del(key)
    end
  end
  describe '#feature_branch' do
    context 'per user' do
      it 'feature branches correctly after storing feature configuration per user in a separate process (ensuring persistence)' do
        user_id = 'email1@example.com'
        ruby_code = <<-RUBY_CODE
          $:.unshift('.')
          require 'redis'
          require 'lib/abstract_feature_branch'
          AbstractFeatureBranch.initialize_user_features_storage
          AbstractFeatureBranch.toggle_features_for_user('#{user_id}', :feature1 => false, :feature3 => true, :feature6 => true, :feature7 => false)
        RUBY_CODE
        system "ruby -e \"#{ruby_code}\""
        features_enabled = []
        feature_branch :feature1, user_id do
          features_enabled << :feature1
        end
        feature_branch :feature3, user_id do
          features_enabled << :feature3
        end
        feature_branch :feature6, user_id do
          features_enabled << :feature6
        end
        feature_branch :feature6, 'otheruser@example.com' do
          features_enabled << :feature6_otheruser
        end
        feature_branch :feature6 do
          features_enabled << :feature6_nouserspecified
        end
        feature_branch :feature7, user_id do
          features_enabled << :feature7
        end
        features_enabled.should include(:feature1) #remains like features.yml
        features_enabled.should_not include(:feature3) #remains like features.yml
        features_enabled.should include(:feature6) #per user honored as true
        features_enabled.should_not include(:feature6_otheruser) #per user honored as false
        features_enabled.should_not include(:feature6_nouserspecified) #per user requires user id or it returns false
        features_enabled.should_not include(:feature7) #per user honored as false
      end
      it 'update feature branching (disabling some features) after having stored feature configuration per user in a separate process (ensuring persistence)' do
        user_id = 'email1@example.com'
        ruby_code = <<-RUBY_CODE
          $:.unshift('.')
          require 'redis'
          require 'lib/abstract_feature_branch'
          AbstractFeatureBranch.initialize_user_features_storage
          AbstractFeatureBranch.toggle_features_for_user('#{user_id}', :feature6 => true, :feature7 => false)
          AbstractFeatureBranch.toggle_features_for_user('#{user_id}', :feature6 => false, :feature7 => true)
        RUBY_CODE
        system "ruby -e \"#{ruby_code}\""
        features_enabled = []
        feature_branch :feature6, user_id do
          features_enabled << :feature6
        end
        feature_branch :feature7, user_id do
          features_enabled << :feature7
        end
        features_enabled.should_not include(:feature6)
        features_enabled.should include(:feature7)
      end

    end
  end
  describe 'self#feature_branch' do
    after do
      Object.send(:remove_const, :TestObject)
    end
    # No need to retest all instance test cases, just a spot check due to implementation reuse
    it 'feature branches instance level behavior (case-insensitive feature names)' do
      class TestObject
        def self.features_enabled
          @features_enabled ||= []
        end
        def self.hit_me
          feature_branch :feature1 do
            self.features_enabled << :feature1
          end
          feature_branch :feature2 do
            self.features_enabled << :feature2
          end
          feature_branch :feature3 do
            self.features_enabled << :feature3
          end
        end
      end
      TestObject.hit_me
      TestObject.features_enabled.should include(:feature1)
      TestObject.features_enabled.should include(:feature2)
      TestObject.features_enabled.should_not include(:feature3)
    end
  end
end

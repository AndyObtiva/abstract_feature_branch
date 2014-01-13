require 'spec_helper'

describe 'feature_branch object extensions' do
  before do
    @app_env_backup = AbstractFeatureBranch.application_environment
    @app_root_backup = AbstractFeatureBranch.application_root
    AbstractFeatureBranch.logger.warn 'Environment variable ABSTRACT_FEATURE_BRANCH_FEATURE1 already set, potentially conflicting with another test' if ENV.keys.include?('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    AbstractFeatureBranch.logger.warn 'Environment variable Abstract_Feature_Branch_Feature2 already set, potentially conflicting with another test' if ENV.keys.include?('Abstract_Feature_Branch_Feature2')
    AbstractFeatureBranch.logger.warn 'Environment variable abstract_feature_branch_feature3 already set, potentially conflicting with another test' if ENV.keys.include?('abstract_feature_branch_feature3')
    AbstractFeatureBranch.user_features_storage.flushall
  end
  after do
    ENV.delete('ABSTRACT_FEATURE_BRANCH_FEATURE1')
    ENV.delete('Abstract_Feature_Branch_Feature2')
    ENV.delete('abstract_feature_branch_feature3')
    AbstractFeatureBranch.application_root = @app_root_backup
    AbstractFeatureBranch.application_environment = @app_env_backup
    AbstractFeatureBranch.unload_application_features
    AbstractFeatureBranch.user_features_storage.flushall
  end
  describe '#feature_branch' do
    context 'per user' do
      it 'feature branches correctly after storing feature configuration per user in a separate process (ensuring persistence)' do
        user_id = 'email1@example.com'
        Process.fork do
          AbstractFeatureBranch.initialize_user_features_storage
          AbstractFeatureBranch.toggle_features_for_user(user_id, :feature1 => true, :feature2 => false, :feature3 => true, :feature5 => true)
        end
        Process.wait
        features_enabled = []
        feature_branch :feature1, user_id do
          features_enabled << :feature1
        end
        feature_branch :feature2, user_id do
          features_enabled << :feature2
        end
        feature_branch :feature3, user_id do
          features_enabled << :feature3
        end
        feature_branch :feature5, user_id do
          features_enabled << :feature5
        end
        feature_branch :feature5, 'otheruser@example.com' do
          features_enabled << :feature5_otheruser
        end
        features_enabled.should include(:feature1)
        features_enabled.should_not include(:feature2)
        features_enabled.should_not include(:feature3)
        features_enabled.should include(:feature5)
        features_enabled.should_not include(:feature5_otheruser)
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

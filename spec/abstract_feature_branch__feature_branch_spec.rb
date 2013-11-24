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
    AbstractFeatureBranch.reload_application_features
    AbstractFeatureBranch.application_environment = @app_env_backup
  end
  describe 'feature_branch' do
    context 'class level behavior (case-insensitive string or symbol feature names)' do
      {
        'Feature1' => true,
        :FEATURE2 => true,
        :feature3 => false,
        :admin_feature1 => true,
        :admin_feature2 => false,
        :public_feature1 => true,
        :public_feature2 => false,
        :wiki_feature1 => true,
        :wiki_feature2 => false,
      }.each do |feature_name, expected_branch_run|
        it "feature branches correctly for feature #{feature_name} with expected branch run #{expected_branch_run}" do
          feature_branch_run = false
          feature_branch feature_name do
            feature_branch_run = true
          end
          feature_branch_run.should == expected_branch_run
        end
      end
    end
    it 'returns nil and does not execute block for an invalid feature name' do
      return_value = feature_branch :invalid_feature_that_does_not_exist do
        fail 'feature branch block must not execute, but did.'
      end
      return_value.should be_nil
    end
    it 'supports an alternate branch of behavior for turned off features' do
      feature_behaviors = []
      feature_branch :feature1,
                     :true => lambda {feature_behaviors << :feature1_true},
                     :false => lambda {feature_behaviors << :feature1_false}
      feature_branch :feature3,
                     :true => lambda {feature_behaviors << :feature3_true},
                     :false => lambda {feature_behaviors << :feature3_false}
      feature_behaviors.should include(:feature1_true)
      feature_behaviors.should_not include(:feature1_false)
      feature_behaviors.should_not include(:feature3_true)
      feature_behaviors.should include(:feature3_false)
    end
    it 'executes alternate branch for an invalid feature name' do
      feature_behaviors = []
      feature_branch :invalid_feature_that_does_not_exist,
                     :true => lambda {feature_behaviors << :main_branch},
                     :false => lambda {feature_behaviors << :alternate_branch}
      feature_behaviors.should_not include(:main_branch)
      feature_behaviors.should include(:alternate_branch)
    end
    it 'allows environment variables (case-insensitive booleans) to override configuration file' do
      ENV['ABSTRACT_FEATURE_BRANCH_FEATURE1'] = 'FALSE'
      ENV['Abstract_Feature_Branch_Feature2'] = 'False'
      ENV['abstract_feature_branch_feature3'] = 'true'
      AbstractFeatureBranch.reload_application_features
      features_enabled = []
      feature_branch :feature1 do
        features_enabled << :feature1
      end
      feature_branch :feature2 do
        features_enabled << :feature2
      end
      feature_branch :feature3 do
        features_enabled << :feature3
      end
      features_enabled.should_not include(:feature1)
      features_enabled.should_not include(:feature2)
      features_enabled.should include(:feature3)
    end
    it 'allows local configuration file to override main configuration file' do
      features_enabled = []
      feature_branch :feature4 do
        features_enabled << :feature4
      end
      feature_branch :feature5 do
        features_enabled << :feature5
      end
      feature_branch :admin_feature3 do
        features_enabled << :admin_feature3
      end
      feature_branch :public_feature3 do
        features_enabled << :public_feature3
      end
      feature_branch :wiki_feature3 do
        features_enabled << :wiki_feature3
      end
      features_enabled.should_not include(:feature4)
      features_enabled.should include(:feature5)
      features_enabled.should include(:admin_feature3)
      features_enabled.should include(:public_feature3)
      features_enabled.should include(:wiki_feature3)
    end
    it 'works with an application that has no configuration files' do
      AbstractFeatureBranch.application_root = File.join(__FILE__, 'application_no_config')
      AbstractFeatureBranch.reload_application_features
      feature_branch :feature1 do
        fail 'feature branch block must not execute, but did.'
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

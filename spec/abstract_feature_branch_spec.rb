require 'spec_helper'

describe 'abstract_feature_branch' do
  describe 'feature_branch' do
    it 'feature branches class level behavior' do
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
      features_enabled.should include(:feature1)
      features_enabled.should include(:feature2)
      features_enabled.should_not include(:feature3)
    end
    it 'returns nil and does not execute block for an invalid feature name' do
      return_value = feature_branch :invalid_feature_that_does_not_exist do
        fail 'feature branch block must have not executed'
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
  end
  describe 'self#feature_branch' do
    after do
      Object.send(:remove_const, :TestObject)
    end
    # No need to retest all instance test cases, just a spot check due to implementation reuse
    it 'feature branches instance level behavior' do
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
  describe 'feature_enabled?' do
    it 'determines whether a feature is enabled or not in features configuration' do
      feature_enabled?(:feature1).should == true
      feature_enabled?(:feature2).should == true
      feature_enabled?(:feature3).should == false
    end
    it 'returns nil for an invalid feature name' do
      feature_enabled?(:invalid_feature_that_does_not_exist).should be_nil
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

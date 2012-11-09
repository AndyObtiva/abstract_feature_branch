require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
module Rails
  def self.root
    File.join(File.dirname(__FILE__), '..')
  end
  def self.env
    'test'
  end
end
require File.join(File.dirname(__FILE__), '..', 'lib', 'abstract_feature_branch')

describe 'abstract_feature_branch' do
  describe 'self#feature_branch' do
    it 'works' do
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
  end
  describe 'feature_branch' do
    it 'works' do
      class TestObject
        attr_reader :features_enabled
        def initialize
          @features_enabled = []
        end
        def hit_me
          feature_branch :feature1 do
            @features_enabled << :feature1
          end
          feature_branch :feature2 do
            @features_enabled << :feature2
          end
          feature_branch :feature3 do
            @features_enabled << :feature3
          end
        end
      end
      test_object = TestObject.new
      test_object.hit_me
      test_object.features_enabled.should include(:feature1)
      test_object.features_enabled.should include(:feature2)
      test_object.features_enabled.should_not include(:feature3)
    end
  end
end
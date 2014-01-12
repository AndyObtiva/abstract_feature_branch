require 'test_helper'

class AbstractFeatureBranchTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, AbstractFeatureBranch
  end
end

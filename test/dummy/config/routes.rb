Rails.application.routes.draw do

  mount AbstractFeatureBranch::Engine => "/abstract_feature_branch"
end

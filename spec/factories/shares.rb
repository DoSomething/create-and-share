FactoryGirl.define do
  factory :share do
    uid { build(:user).uid }
    post
  end
end
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do
    campaign_id 1
    post_id 1
    column "MyString"
    value "MyString"
  end
end

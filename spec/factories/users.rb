FactoryGirl.define do
  factory :user do
    email 'bohemian_test@bohemian.cc'
    fbid nil
    uid 703718
    mobile 1234567890
    is_admin false

    trait :admin do
      is_admin true
    end
  end
end
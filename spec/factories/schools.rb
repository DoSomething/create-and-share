# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
    gsid 1
    title { Faker::Lorem.words.join(" ") }
    state { Faker::Address.state_abbr }
    city { Faker::Address.city }
    zip  { Faker::Address.zip }
  end
end

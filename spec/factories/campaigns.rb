# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :campaign do
    title { Faker::Lorem.words.join(" ") }
    start_date { Date.today.prev_month }
    end_date { Date.today.next_month }
    path { Faker::Internet.domain_word }
    lead { Faker::Name.name }
    lead_email { Faker::Internet.email }
    developers { Faker::Internet.email }
    description { Faker::Lorem.paragraph }
    image nil
    gated true
    meme_header { Faker::Lorem.words.join(" ") }
  end
end

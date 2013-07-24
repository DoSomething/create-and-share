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
    image File.new(Rails.root + 'spec/mocks/ruby.png')
    gated true
    meme_header { Faker::Lorem.words.join(" ") }
    email_submit { Faker::Lorem.word }
    email_signup { Faker::Lorem.word }
    mailchimp 'PicsforPets2013'
    mobile_commons "158551"
  end
end

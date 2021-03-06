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
    image Rack::Test::UploadedFile.new(Rails.root + 'spec/mocks/ruby.png', 'image/png')
    gated 'all'
    facebook 'mine'
    has_school_field true
    paged_form false
    meme true
    meme_header { Faker::Lorem.words.join(" ") }
    email_submit { Faker::Lorem.word }
    email_signup { Faker::Lorem.word }
    mailchimp 'PicsforPets2013'
    mobile_commons "158551"
    stat_frequency 0
    allow_revoting true
  end
end

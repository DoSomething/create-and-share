require 'faker'

FactoryGirl.define do
  factory :post do
    uid 1263777
    adopted false
    meme_text { Faker::Lorem.sentence }
    meme_position 'bottom'
    flagged false
    image Rack::Test::UploadedFile.new(Rails.root + 'spec/mocks/ruby.png', 'image/png')
    name { Faker::Name.first_name }
    promoted false
    share_count 0
    state { Faker::Address.state_abbr }
    city { Faker::Address.city }
    extras {
      { :animal_type => 'cat', :shelter => 'Cats' }
    }
    processed_from_url nil
    school_id 0
    story { Faker::Lorem.paragraph }
    campaign

    factory :promo do
      promoted true
    end
  end
end

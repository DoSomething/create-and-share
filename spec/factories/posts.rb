require 'faker'

FactoryGirl.define do
  factory :post do
    uid { build(:user).uid }
    adopted false
    meme_text { Faker::Lorem.sentence }
    meme_position 'bottom'
    flagged false
    image Rack::Test::UploadedFile.new(Rails.root + 'spec/mocks/ruby.png', 'image/png')
    name { Faker::Name.first_name }
    promoted false
    share_count 0
    state { get_states.keys.sample.to_s }
    city { Faker::Address.city }
    extras {
      { :animal_type => 'cat', :shelter => 'Cats' }
    }
    processed_from_url nil
    story { Faker::Lorem.paragraph }
    campaign
    school

    factory :promo do
      promoted true
    end
  end
end

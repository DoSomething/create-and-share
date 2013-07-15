FactoryGirl.define do
  factory :api_key do
    key 'aea12e3fe5f83f0d574fdff0342aba91'
  end

  factory :post do
    uid 1263777
    adopted false
    meme_text 'Bottom text'
    meme_position 'bottom'
    flagged false
    image File.new(Rails.root + 'spec/mocks/ruby.png')
    name 'Spot the kitten'
    promoted false
    share_count 0
    state 'PA'
    city 'Pittsburgh'
    extras {
      { :animal_type => 'cat', :shelter => 'Cats' }
    }
    story "This is a story"
    campaign_id { Campaign.last ? Campaign.last.id : 1 }
  end

  factory :user do
    email 'test@subject.com'
    fbid nil
    uid 1263777
    is_admin false
  end

  factory :share do
    post_id 1
    uid 1263777
  end
end
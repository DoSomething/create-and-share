FactoryGirl.define do
  factory :api_key do
    key 'aea12e3fe5f83f0d574fdff0342aba91'
  end

  factory :post do
    uid 703718
    adopted false
    meme_text 'Bottom text'
    meme_position 'bottom'
    flagged false
    image File.new(Rails.root + 'spec/mocks/ruby.png')
    name 'Spot the kitten'
    promoted false
    share_count 0
    shelter 'Cats'
    state 'PA'
    city 'Pittsburgh'
    story "This is a story"
    animal_type 'cat'
  end

  factory :user do
    email 'mchitten@gmail.com'
    fbid nil
    uid 778374
    is_admin false
  end
end
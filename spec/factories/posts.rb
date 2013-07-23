require 'faker'

FactoryGirl.define do
	factory :post do
		uid 1263777
		adopted false
		meme_text { Faker::Lorem.sentence }
		meme_position 'bottom'
		flagged false
		image File.new(Rails.root + 'spec/mocks/ruby.png')
		name { Faker::Name.name }
		promoted false
		share_count 0
		state { Faker::Address.state_abbr }
		city { Faker::Address.city }
		extras {
			{ :animal_type => 'cat', :shelter => 'Cats' }
		}
		story { Faker::Lorem.paragraph }
		campaign
	end
end
FactoryGirl.define do
	factory :user do
		email 'test@subject.com'
		fbid nil
		uid 1263777
		mobile 1234567890
		is_admin false
	end

	factory :admin_user, class: User do
		email 'fueledbymarvin@gmail.com'
		fbid 594889925
		uid 1234184
		mobile 1234567890
		is_admin true
	end
end
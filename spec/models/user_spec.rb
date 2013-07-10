require 'spec_helper'

describe User do

	before { @user = FactoryGirl.create(:user) }

	subject { @user }

	it { should respond_to(:email) }
	it { should respond_to(:fbid) }
	it { should respond_to(:uid) }
	it { should respond_to(:is_admin) }

	it { should be_valid }
	it { should_not be_is_admin }

	describe "with admin attribute set to 'true'" do
		before do
			@user.save!
			@user.toggle!(:is_admin)
		end

		it { should be_is_admin }
	end
end
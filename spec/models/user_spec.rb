require 'spec_helper'

describe User do
	it 'has a valid factory' do
		FactoryGirl.create(:user).should be_valid
	end

	describe 'existence' do
		before { @user = FactoryGirl.build(:user) }

		it 'exists if email is in drupal database' do
			User.exists?(@user.email).should eq true
		end
		it 'exists if it is a phone number' do
			@user.email = "1234567890"
			User.exists?(@user.email).should eq true
		end
		it 'does not exist if email is not in drupal database' do
			@user.email = "iamafailure@thisdoesnotevenexist.com"
			User.exists?(@user.email).should eq false
		end		
	end

	describe 'registration' do
		it 'registers new accounts' do
			email = 'void-' + Time.now.to_i.to_s + '@dosomething.org'
			User.register("test", email, "123456789", "test", "test", "1234567890", "10/05/2000")
			User.exists?(email).should eq true
		end
		it 'does not try to register existing accounts' do
			User.register("test", "test@subject.com", "123456789", "test", "test", "1234567890", "10/05/2000").should eq false
		end
	end

	describe 'login' do
		before :each do
			@user = FactoryGirl.create(:user)
			@session = {}
			@campaign = FactoryGirl.create(:campaign)
		end

		it 'logs in existing users' do
			User.login(@campaign, @session, @user.email, "test", "", 0)
			@session[:drupal_user_id].should eq @user.uid.to_s
		end
		it 'logs in existing users with cell phone' do
			User.login(@campaign, @session, "5714906806", "doitdiditdone", "", 0)
			@session[:drupal_user_id].should eq "1234184"
		end
		it 'logs in through Facebook' do
			User.login(@campaign, @session, @user.email, "test", "", 123)
			@session[:drupal_user_id].should eq @user.uid.to_s
		end
		it 'does not login nonexistent users' do
			User.login(@campaign, @session, @user.email, "test", "", "")
			@session[:drupal_user_id].should eq @user.uid.to_s
		end

		context 'logging in new CAS users' do
			before :each do
				@email = 'void-' + Time.now.to_i.to_s + '@dosomething.org'
				User.register("test", @email, "123456789", "test", "test", "1234567890", "10/05/2000")
			end
			it 'adds users who are not in the CAS database' do
				User.login(@campaign, @session, @email, "test", "", 0)
				User.find_by_uid(@session[:drupal_user_id]).should_not eq nil
			end
			describe 'it emails them if they have not done the campaign yet' do
				after { User.login(@campaign, @session, @email, "test", "", 0) }
				it 'sends through Mailchimp' do
					Services::MailChimp.should_receive(:subscribe).with(@email, @campaign.mailchimp)
				end
				it 'sends through Mandrill' do
					Services::Mandrill.should_receive(:mail).with(@campaign.lead, @campaign.lead_email, @email, @campaign.email_signup)
				end
				
			end
		end
	end
end
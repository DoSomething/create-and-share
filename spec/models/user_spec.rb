require 'spec_helper'

describe User do
	let(:campaign) { FactoryGirl.create(:campaign) }

	before :each do
		@user = FactoryGirl.build(:user)
		Services::MailChimp.stub(:subscribe)
		Services::Mandrill.stub(:mail)
		Services::MobileCommons.stub(:subscribe)
		Services::Auth.stub(:check_exists).and_return([{"uid" => @user.uid}])
		Services::Auth.stub(:check_admin).and_return([])
	end

	it 'has a valid factory' do
		FactoryGirl.create(:user).should be_valid
	end

	it { FactoryGirl.create(:user).should respond_to(:participations) }
	it { FactoryGirl.create(:user).should respond_to(:campaigns) }

	describe 'existence' do
		it 'exists if email is in drupal database' do
			User.exists?(@user.email).should eq true
		end

		it 'exists if it is a phone number' do
			@user.email = "1234567890"
			User.exists?(@user.email).should eq true
		end

		it 'does not exist if email is not in drupal database' do
			Services::Auth.stub(:check_exists).and_return([])
			User.exists?(@user.email).should eq false
		end		
	end

	describe 'registration' do
		before :each do
			@request_object = HTTParty::Request.new Net::HTTP::Get, '/'
			@parsed_response = lambda { {"foo" => "bar"} }
		end

		it 'registers new accounts' do
			# fake a good response
		    response_object = Net::HTTPOK.new('1.1', 200, 'OK')
		    response_object.stub(:body => "{foo:'bar'}")
		    response = HTTParty::Response.new(@request_object, response_object, @parsed_response)
			Services::Auth.stub(:register).and_return(response)

			User.register("test", "test@subject.com", "123456789", "test", "test", "1234567890", "10/05/2000")
			User.exists?("test@suject.com").should eq true
		end

		it 'does not try to register existing accounts' do
			# fake a bad response
		    response_object = Net::HTTPOK.new('1.1', 404, 'OK')
		    response_object.stub(:body => "{foo:'bar'}")
		    response = HTTParty::Response.new(@request_object, response_object, @parsed_response)
			Services::Auth.stub(:register).and_return(response)

			User.register("test", "test@subject.com", "123456789", "test", "test", "1234567890", "10/05/2000").should eq false
		end
	end

	describe 'login' do
		before :each do
			@session = {}
			@campaign = FactoryGirl.create(:campaign)
		end

		describe 'logs in existing users' do
			before :each do
				request_object = HTTParty::Request.new Net::HTTP::Get, '/'
				parsed_response = lambda { {"user" => {"uid" => @user.uid, "roles" => {"values" => "test"}}, "profile" => {"field_user_mobile" => ""}} }
				response_object = Net::HTTPOK.new('1.1', 200, 'OK')
				response_object.stub(:body => "{foo:'bar'}")
				response = HTTParty::Response.new(request_object, response_object, parsed_response)
				Services::Auth.stub(:login).and_return(response)
			end

			it 'logs in existing users' do
				User.login(@campaign, @session, @user.email, "test", "", 0)
				@session[:drupal_user_id].should eq @user.uid
			end

			it 'logs in through Facebook' do
				User.login(@campaign, @session, @user.email, "test", "", 123)
				@session[:drupal_user_id].should eq @user.uid
			end
		end

		it 'does not login nonexistent users' do
			# fakes failed login
			request_object = HTTParty::Request.new Net::HTTP::Get, '/'
			parsed_response = lambda { {"foo" => "bar"} }
			response_object = Net::HTTPOK.new('1.1', 404, 'OK')
			response_object.stub(:body => "{foo:'bar'}")
			response = HTTParty::Response.new(request_object, response_object, parsed_response)
			Services::Auth.stub(:login).and_return(response)

			User.login(@campaign, @session, "awoefj@aofeij.com", "awefsd", "", 0).should eq false
		end

		describe 'logging in new CAS users' do
			before :each do
				request_object = HTTParty::Request.new Net::HTTP::Get, '/'
				parsed_response = lambda { {"user" => {"uid" => @user.uid, "roles" => {"values" => "test"}}, "profile" => {"field_user_mobile" => ""}} }
				response_object = Net::HTTPOK.new('1.1', 200, 'OK')
				response_object.stub(:body => "{foo:'bar'}")
				response = HTTParty::Response.new(request_object, response_object, parsed_response)
				Services::Auth.stub(:login).and_return(response)
			end

			it 'adds users who are not in the CAS database' do
				User.login(@campaign, @session, "test@subject.com", "test", "", 0)
				User.find_by_uid(@session[:drupal_user_id]).should_not eq nil
			end

			it 'does not add users who are already in the CAS database' do
				@user = FactoryGirl.create(:user)
				expect{ User.login(@campaign, @session, @user.email, "test", "", 0) }.to_not change{ User.count }.by(1)
			end
		end
	end

	describe 'Mailchimp and MobileCommons' do
		before :each do
			@campaign = FactoryGirl.create(:campaign)
		end
		after { @user.handle_mc(@campaign) }
		
		it 'through Mailchimp' do
			Services::MailChimp.should_receive(:subscribe).with(@user.email, @campaign.mailchimp)
		end
		
		it 'through Mandrill' do
			Services::Mandrill.should_receive(:mail).with(@campaign.lead, @campaign.lead_email, @user.email, @campaign.email_signup)
		end
		
		it 'through MobileCommons' do
			Services::MobileCommons.should_receive(:subscribe).with(@user.mobile, @campaign.mobile_commons)
		end
	end

	describe 'action count' do
		before :each do
			@user = FactoryGirl.create(:user)
			@post = FactoryGirl.create(:post, campaign_id: campaign.id)
		end

		it 'increases on voting' do
			expect { @user.vote_for(@post) }.to change { @user.action_count(campaign.id) }.by(1)
		end

		it 'increases on sharing' do
			expect { FactoryGirl.create(:share, uid: @user.uid, post_id: @post.id) }.to change { @user.action_count(campaign.id) }.by(1)
		end
	end
end
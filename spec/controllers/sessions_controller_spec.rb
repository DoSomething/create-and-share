require 'spec_helper'

describe SessionsController, :type => :controller do
  let(:login_params) { { :form => 'login', :session => { :password => 'test' } } }
  let(:register_params) { {
          :form => 'register',
          :session => {
            :username => nil,
            :password => 'test',
            :first => 'Test',
            :last => 'User',
            :cell => '610-555-4493',
            :month => 10,
            :day => 05,
            :year => 2000,
          }
        } }

  before :each do
    @campaign = FactoryGirl.create(:campaign)
    Services::MailChimp.stub(:subscribe)
    Services::Mandrill.stub(:mail)
    Services::MobileCommons.stub(:subscribe)
    Services::Auth.stub(:check_admin).and_return([])
    request_object = HTTParty::Request.new Net::HTTP::Get, '/'
    parsed_response = lambda { {"user" => {"uid" => "1263777", "roles" => {"values" => "test"}}, "profile" => {"field_user_mobile" => ""}} }
    response_object = Net::HTTPOK.new('1.1', 200, 'OK')
    response_object.stub(:body => "{foo:'bar'}")
    response = HTTParty::Response.new(request_object, response_object, parsed_response)
    Services::Auth.stub(:login).and_return(response)
    Services::Auth.stub(:register).and_return(response)
  end

  # POST create
  describe 'login / register process' do
    context 'user exists' do
      before :each do
        @user = FactoryGirl.build(:user)
        Services::Auth.stub(:check_exists).and_return([{"uid" => "1263777"}])
      end

      describe 'logs in user' do
        before :each do
          @params = login_params
          @params[:session][:username] = @user.email
        end

        context 'with campaign' do
          before :each do
            @params[:session][:campaign] = @campaign.id
            post :create, @params
          end

          specify 'login' do
            # Make sure it redirects us to participation
            expect(response).to redirect_to participation_path(:campaign_path => @campaign.path)

            # Make sure session was set
            session["drupal_user_id"].should eq @user.uid.to_s
            flash[:message].should eq "You've logged in successfully!"
          end

          specify 'logout' do
            delete :destroy
            session["drupal_user_id"].should eq nil
            expect(response).to redirect_to root_path(:campaign_path => '')
          end
        end

        context 'without campaign' do
          before :each do
            post :create, @params
          end

          specify 'login' do
            # Make sure it redirects us to root
            expect(response).to redirect_to root_path(:campaign_path => '')

            # Make sure session was set
            session["drupal_user_id"].should eq @user.uid.to_s
            flash[:message].should eq "You've logged in successfully!"
          end

          specify 'logout' do
            delete :destroy
            session["drupal_user_id"].should eq nil
            expect(response).to redirect_to root_path(:campaign_path => '')
          end
        end
      end

      describe 'does not register user' do
        before :each do
          @params = register_params
          @params[:session][:email] = @user.email
        end

        specify 'with campaign' do
          @params[:session][:campaign] = @campaign.id
          post :create, @params

          # Make sure it redirects to login
          expect(response).to redirect_to login_path(:campaign_path => @campaign.path)

          # Make sure session was not set
          session["drupal_user_id"].should eq nil
          flash[:error].should eq "A user with that account already exists."
        end

        specify 'without campaign' do
          post :create, @params

          # Make sure it redirects to login
          expect(response).to redirect_to '/login'

          # Make sure session was not set
          session["drupal_user_id"].should eq nil
          flash[:error].should eq "A user with that account already exists."
        end
      end
    end

    context 'user does not exist' do
      before :each do
        @user = FactoryGirl.build(:user)
        Services::Auth.stub(:check_exists).and_return([])
      end

      describe 'does not login user' do
        before :each do
          @params = login_params
          @params[:session][:username] = @user.email
        end

        specify 'with campaign' do
          @params[:session][:campaign] = @campaign.id
          post :create, @params

          # Make sure it redirects us to login
          expect(response).to redirect_to login_path(:campaign_path => @campaign.path)

          # Make sure session was not set
          session["drupal_user_id"].should eq nil
          flash[:error].should eq "Invalid username / password."
        end

        specify 'without campaign' do
          post :create, @params

          # Make sure it redirects us to login
          expect(response).to redirect_to '/login'

          # Make sure session was not set
          session["drupal_user_id"].should eq nil
          flash[:error].should eq "Invalid username / password."
        end
      end

      describe 'registers user' do
        before :each do
          @params = register_params
          @params[:session][:email] = @user.email
        end

        specify 'with campaign' do
          @params[:session][:campaign] = @campaign.id
          post :create, @params

          # Make sure it redirects to participation
          expect(response).to redirect_to participation_path(:campaign_path => @campaign.path)

          # Make sure session was set
          session["drupal_user_id"].should eq @user.uid.to_s
          flash[:message].should eq "You've registered successfully!"
        end

        specify 'without campaign' do
          post :create, @params

          # Make sure it redirects to root
          expect(response).to redirect_to root_path(:campaign_path => '')

          # Make sure session was set
          session["drupal_user_id"].should eq @user.uid.to_s
          flash[:message].should eq "You've registered successfully!"
        end
      end
    end
  end
end
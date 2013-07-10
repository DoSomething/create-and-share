require 'spec_helper'

describe SessionsController, :type => :controller do
  describe 'login / register process' do
    it '1. Logs in' do
      # Login
      post :create, {
        :form => 'login',
        :session => {
          :username => 'bohemian_test',
          :password => 'bohemian_test'
        }
      }

      # Make sure it redirects us to root
      expect(response).to redirect_to :root

      # Make sure the user is in our database.
      user = User.last
      user.uid.should_not eq nil
      user.email.should_not eq nil

      # Make sure the user is in the Drupal database.
      status = Services::Auth.login('bohemian_test', 'bohemian_test')
      status.code.should eq 200
      status['user']['uid'].should_not eq nil
    end

    # Register
    it '2. Registers' do
      e = 'test-user' + Time.now.to_i.to_s + '@dosomething.org'
      post :create, {
        :form => 'register',
        :session => {
          :username => nil,
          :password => 'testing123',
          :email => e,
          :first => 'Test',
          :last => 'User',
          :cell => '610-555-4493',
          :month => 10,
          :day => 05,
          :year => 2000
        }
      }

      expect(response).to redirect_to :root

      user = User.last
      user.uid.should_not eq nil
      user.email.should eq e

      status = Services::Auth.login(e, 'testing123')
      status.code.should eq 200
      status['user']['uid'].should_not eq nil
    end
  end
end
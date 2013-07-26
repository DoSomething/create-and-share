require 'spec_helper'

describe UsersController, :type => :controller do
	it 'saves intent' do
		session = { drupal_user_id: '1263777', drupal_user_role: { test: 'authenticated user' } }
		expect { get :intent, {}, @session }.to change { @user.intent }.to(true)
	end
end
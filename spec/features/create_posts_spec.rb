require 'spec_helper'

feature 'Create posts' do
  let(:campaign) { FactoryGirl.create(:campaign) }

  background do
    login(:user)
  end

  scenario 'User can create a valid post'

  scenario 'User gets errors when submitting an invalid form'
end
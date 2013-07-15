require 'spec_helper'

describe DashboardController, :type => :controller do
  let(:campaign) { FactoryGirl.create(:campaign) }

  describe 'GET #index' do
    it 'redirects to login' do
      get :index, :campaign_path => campaign.path
      expect(response).to redirect_to '/login'
    end

    it 'shows index' do
      get :index, :campaign_path => campaign.path, :bypass => true

      expect(response).to be_success
      expect(response.status).to eq 200
      expect(response).to render_template 'index'
    end
  end
end

require 'spec_helper'

describe PostsController, :type => :controller do
  let(:key) { FactoryGirl.create(:api_key) }
  let(:campaign) { FactoryGirl.create(:campaign) }

  describe 'GET #index.json' do
    it 'fails' do
      get :index, :campaign_path => campaign.path, :format => :json
      expect(response).to be_forbidden
    end
    it 'succeeds' do
      get :index, :campaign_path => campaign.path, :format => :json, :key => key.key
      expect(response.status).to eq 200
    end
  end

  describe 'GET #filter.json' do
    it 'fails' do
      get :filter, :campaign_path => campaign.path, :atype => 'cats', :run => 'animal', :format => :json
      expect(response).to be_forbidden
    end
    it 'succeeds' do
      get :filter, :campaign_path => campaign.path, :atype => 'cats', :run => 'animal', :format => :json, :key => key.key
      expect(response.status).to eq 200
    end
  end
end
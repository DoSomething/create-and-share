require 'spec_helper'

describe PostsController, :type => :controller do
  let(:key) { FactoryGirl.create(:api_key) }
  let(:campaign) { FactoryGirl.create(:campaign) }

  before do
    @post = FactoryGirl.create(:post, campaign_id: campaign.id)
  end

  describe 'GET #index.json' do
    it 'fails with an invalid key' do
      get :index, :campaign_path => campaign.path, :format => :json
      expect(response).to be_forbidden
    end
    it 'succeeds with a valid key' do
      get :index, :campaign_path => campaign.path, :format => :json, :key => key.key
      expect(response.status).to eq 200
    end
  end

  describe 'GET #filter.json' do
    before { add_config(campaign.path) }
    after { remove_config(campaign.path) }

    it 'fails with an invalid key' do
      get :filter, :campaign_path => campaign.path, :filter => 'cats', :format => :json
      expect(response).to be_forbidden
    end
    it 'succeeds with a valid key' do
      get :filter, :campaign_path => campaign.path, :filter => 'cats', :format => :json, :key => key.key
      expect(response.status).to eq 200
    end
  end
end
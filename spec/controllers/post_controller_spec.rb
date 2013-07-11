require 'spec_helper'

describe PostsController, :type => :controller do
  let(:campaign) { FactoryGirl.create(:campaign) }

  describe 'GET #index' do
    it 'redirects to login' do
      get :index, :campaign_path => campaign.path
      expect(response).to redirect_to :login
    end

    it 'shows index' do
      get :index, :campaign_path => campaign.path, :bypass => true

      expect(response).to be_success
      expect(response.status).to eq 200
      expect(response).to render_template 'index'
    end
  end

  describe 'GET #filter' do
    it 'redirects to login' do
      get :show_filter, campaign_path: campaign.path, filter: 'cats' 
      expect(response).to redirect_to :login
    end

    it 'show filter' do
      get :show_filter, campaign_path: campaign.path, filter: 'cats', bypass: true

      expect(response).to be_success
      expect(response.status).to eq 200
      expect(response).to render_template 'filter'
    end
  end

  describe 'GET #new' do
    it 'redirects to login' do
      get :new, :campaign_path => campaign.path
      expect(response).to redirect_to :login
    end

    it 'shows submit' do
      get :new, :campaign_path => campaign.path, :bypass => true
      expect(response).to be_success
      expect(response.status).to eq 200
      expect(response).to render_template 'new'
    end
  end
end
require 'spec_helper'

describe PostsController, :type => :controller do
  before :each do
    FactoryGirl.create(:api_key)
  end

  describe 'GET #index.json' do
    it 'fails' do
      get :index, :format => :json
      expect(response).to be_forbidden
    end
    it 'succeeds' do
      get :index, :format => :json, :key => 'aea12e3fe5f83f0d574fdff0342aba91'
      expect(response.status).to eq 200
    end
  end

  describe 'GET #filter.json' do
    it 'fails' do
      get :filter, :atype => 'cats', :run => 'animal', :format => :json
      expect(response).to be_forbidden
    end
    it 'succeeds' do
      get :filter, :atype => 'cats', :run => 'animal', :format => :json, :key => 'aea12e3fe5f83f0d574fdff0342aba91'
      expect(response.status).to eq 200
    end
  end
end
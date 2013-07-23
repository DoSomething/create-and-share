require 'spec_helper'

describe ApiKey do
  it 'Finds by id' do
    api = FactoryGirl.create(:api_key)
    a = ApiKey.find_by_key(api.key)
    a.key.should eq 'aea12e3fe5f83f0d574fdff0342aba91'
  end
end
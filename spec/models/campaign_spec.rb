require 'spec_helper'

describe Campaign do
  before :each do
    @campaign = FactoryGirl.create(:campaign)
  end

  it '1. Creates a campaign' do
    @campaign.id.should_not eq nil
  end

  it '2. Finds a campaign' do
    @cmp = Campaign.where(:path => 'picsforpets').first
    @cmp.id.should_not eq nil
  end
end

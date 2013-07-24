require 'spec_helper'

describe Campaign do
  it 'has a valid factory' do
    FactoryGirl.create(:campaign).should be_valid
  end

  describe 'validations' do
    it 'is invalid without a title' do
      FactoryGirl.build(:campaign, title: nil).should_not be_valid      
    end

    it 'is invalid without a description' do
      FactoryGirl.build(:campaign, description: nil).should_not be_valid      
    end

    it 'is invalid without a start date' do
      FactoryGirl.build(:campaign, start_date: nil).should_not be_valid      
    end

    it 'is invalid without an end date' do
      FactoryGirl.build(:campaign, end_date: nil).should_not be_valid      
    end

    it 'is invalid without a path' do
      FactoryGirl.build(:campaign, path: nil).should_not be_valid      
    end

    it 'is invalid without a mailchimp' do
      FactoryGirl.build(:campaign, mailchimp: nil).should_not be_valid      
    end

    it 'is invalid without a mobile commons' do
      FactoryGirl.build(:campaign, mobile_commons: nil).should_not be_valid      
    end

    it 'is invalid without an email sign up' do
      FactoryGirl.build(:campaign, email_signup: nil).should_not be_valid      
    end

    it 'is invalid without an email submit' do
      FactoryGirl.build(:campaign, email_submit: nil).should_not be_valid      
    end

    it 'is invalid without a meme header' do
      FactoryGirl.build(:campaign, meme_header: nil).should_not be_valid      
    end

    it 'is invalid without a lead email' do
      FactoryGirl.build(:campaign, lead_email: nil).should_not be_valid      
    end

    it 'is invalid without developers' do
      FactoryGirl.build(:campaign, developers: nil).should_not be_valid      
    end

    it 'is invalid without an image' do
      FactoryGirl.build(:campaign, image: nil).should_not be_valid      
    end

    it 'is invalid without a lead' do
      FactoryGirl.build(:campaign, lead: nil).should_not be_valid      
    end

    it 'has unique paths' do
      FactoryGirl.create(:campaign, path: 'used')
      FactoryGirl.build(:campaign, path: 'used').should_not be_valid
    end
  end

  describe 'tells you if it is gated' do
    before { @campaign = FactoryGirl.create(:campaign) }

    it 'is gated' do
      @campaign.gated?.should eq true
    end

    it 'is not gated' do
      @campaign.gated = false
      @campaign.gated?. should eq false

    end
  end
end

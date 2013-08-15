require 'spec_helper'

describe Campaign do
  it 'has a valid factory' do
    FactoryGirl.create(:campaign).should be_valid
  end

  it { FactoryGirl.create(:campaign).should respond_to(:participations) }
  it { FactoryGirl.create(:campaign).should respond_to(:users) }

  describe 'validations' do
    let(:campaign) { FactoryGirl.build(:campaign) }
    it 'is invalid without a title' do
      campaign.title = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a description' do
      campaign.description = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a start date' do
      campaign.start_date = nil
      campaign.should_not be_valid
    end

    it 'is invalid without an end date' do
      campaign.end_date = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a path' do
      campaign.path = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a mailchimp' do
      campaign.mailchimp = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a mobile commons' do
      campaign.mobile_commons = nil
      campaign.should_not be_valid
    end

    it 'is invalid without an email sign up' do
      campaign.email_signup = nil
      campaign.should_not be_valid
    end

    it 'is invalid without an email submit' do
      campaign.email_submit = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a lead email' do
      campaign.lead_email = nil
      campaign.should_not be_valid
    end

    it 'is invalid without developers' do
      campaign.developers = nil
      campaign.should_not be_valid
    end

    it 'is invalid without an image' do
      campaign.image = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a lead' do
      campaign.lead = nil
      campaign.should_not be_valid
    end

    it 'is invalid without a facebook share type' do
      campaign.facebook = nil
      campaign.should_not be_valid
    end

    it 'has unique paths' do
      FactoryGirl.create(:campaign, path: 'used')
      FactoryGirl.build(:campaign, path: 'used').should_not be_valid
    end

    it 'does not have a meme_header if meme is false' do
      campaign = FactoryGirl.create(:campaign, meme_header: "should not be here", meme: false)
      campaign.meme_header.should eq ""
    end
  end

  describe 'tells you if it is gated' do
    before { @campaign = FactoryGirl.create(:campaign) }

    it 'is fully gated' do
      @campaign.gated?('all').should eq true
    end

    it 'is gated on the submit page' do
      @campaign.gated = 'submit'
      @campaign.gated?('all').should eq false
      @campaign.gated?('submit').should eq true
    end

    it 'is not gated' do
      @campaign.gated = ''
      @campaign.gated?('all').should eq false
      @campaign.gated?('submit').should eq false
    end
  end
end

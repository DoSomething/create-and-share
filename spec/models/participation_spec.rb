require 'spec_helper'

describe Participation do
  it 'has a valid factory' do
    FactoryGirl.create(:participation).should be_valid
  end

  describe 'is associated with users and campaigns' do
    subject { FactoryGirl.create(:participation) }
    it { should respond_to(:user) }
    it { should respond_to(:campaign) }
  end

  describe 'validations' do
    it 'is not valid without a user' do
      FactoryGirl.build(:participation, user_id: nil).should_not be_valid
    end

    it 'is not valid without a campaign' do
      FactoryGirl.build(:participation, campaign_id: nil).should_not be_valid
    end
  end
end

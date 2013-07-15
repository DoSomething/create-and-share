require 'spec_helper'

describe Tag do
  it 'has a valid factory' do
    FactoryGirl.create(:post).should be_valid
  end

  describe 'Validations' do
    before :each do
      @tag = FactoryGirl.build(:tag)
    end

    it 'is invalid without campaign_id' do
      @tag.campaign_id = nil
      @tag.should_not be_valid
    end

    it 'is invalid with a non-numeric campaign_id' do
      @tag.campaign_id = 'abc'
      @tag.should_not be_valid
    end

    it 'is invalid without post_id' do
      @tag.post_id = nil
      @tag.should_not be_valid
    end

    it 'is invalid without numeric post_id' do
      @tag.post_id = 'abc'
      @tag.should_not be_valid
    end

    it 'is invalid without column' do
      @tag.column = nil
      @tag.should_not be_valid
    end

    it 'is invalid without value' do
      @tag.value = nil
      @tag.should_not be_valid
    end
  end
end

require 'spec_helper'

describe Share do
  it "has a valid factory" do
    FactoryGirl.create(:share).should be_valid
  end

  it "is invalid without post_id" do
    FactoryGirl.build(:share, post_id: nil).should_not be_valid
  end

  it "is invalid without a numeric post_id" do
    FactoryGirl.build(:share, post_id: 'abc').should_not be_valid
  end

  it "is invalid without uid" do
    FactoryGirl.build(:share, uid: nil).should_not be_valid
  end

  it "is invalid without a numeric uid" do
    FactoryGirl.build(:share, uid: 'abc').should_not be_valid
  end

  it "returns a count for a specific post." do
    share = FactoryGirl.create(:share)
    Share.total(:post, share.post.id).should eq 1
  end

  it "returns a count for a specific user" do
  	share = FactoryGirl.create(:share)
  	Share.total(:user, share.post.uid).should eq 1
  end
end
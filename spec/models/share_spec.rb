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
    post = FactoryGirl.create(:post)
    share = FactoryGirl.create(:share, post_id: post.id)

    Share.total(:post, post.id).should eq 1
  end

  it "returns a count for a specific user" do
  	post = FactoryGirl.create(:post)
  	share = FactoryGirl.create(:share, uid: post.uid)

  	Share.total(:user, post.uid).should eq 1
  end
end
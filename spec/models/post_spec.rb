require 'spec_helper'

describe Post do
  it '1. Creates' do
    post = FactoryGirl.create(:post)
    post.id.should_not == nil
  end

  it '2. Finds by id' do
    post = FactoryGirl.create(:post)
    p = Post.find_by_id(post.id)
    p.uid.should eq 703718
  end

  it '3. Deletes' do
    post = FactoryGirl.create(:post)

    po = Post.find_by_id(post.id)
    Post.destroy po

    again = Post.find_by_id(post.id)
    again.should eq nil
  end
end
require 'spec_helper'

describe PostObserver do
  before :each do
    @post = FactoryGirl.create(:post)
  end

  it 'alerts tags to a new post' do
    Tag.where(post_id: @post.id).count.should eq 2
  end
end

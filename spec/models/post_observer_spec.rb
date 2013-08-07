require 'spec_helper'

describe PostObserver do
  before :each do
  	extras = { language: "ruby", pokemon_of_choice: "gengar" }
  	@nExtras = extras.length
    @post = FactoryGirl.create(:post, extras: extras)
  end

  it 'alerts tags to a new post' do
    Tag.where(post_id: @post.id).count.should eq @nExtras
  end
end

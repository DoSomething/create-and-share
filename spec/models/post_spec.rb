require 'spec_helper'

describe Post do
  before { Services::Mandrill.stub(:mail) }

  it 'has a valid factory' do
    FactoryGirl.create(:post).should be_valid
  end

  describe 'validations' do
    it 'is invalid without a name' do
      FactoryGirl.build(:post, name: nil).should_not be_valid      
    end

    it 'is invalid without a city' do
      FactoryGirl.build(:post, city: nil).should_not be_valid
    end

    it 'is invalid without state' do
      FactoryGirl.build(:post, state: nil).should_not be_valid
    end

    it 'is invalid with a longer state' do
      FactoryGirl.build(:post, state: 'PAX').should_not be_valid
    end

    it 'is invalid without a valid state' do
      FactoryGirl.build(:post, state: '12').should_not be_valid
    end

    it 'is invalid without campaign_id' do
      FactoryGirl.build(:post, campaign_id: nil).should_not be_valid
    end

    it 'is invalid without image' do
      FactoryGirl.build(:post, image: nil).should_not be_valid
    end
  end

  describe 'methods' do
    it 'should be able to find by extra tagged fields' do
      cat = FactoryGirl.create(:post, extras: { animal_type: "cat" })
      dog = FactoryGirl.create(:post, extras: { animal_type: "dog" })
      cats = Post.tagged({animal_type: "cat"})
      cats.should include(cat)
      cats.should_not include(dog)
    end

    it 'has a per page count' do
      Post.per_page.should == 10
    end

    it 'should be able to count shares' do
      share = FactoryGirl.create(:share)
      post = share.post
      post.total_shares.should be > 0
    end

    it 'should send an email after a post is created' do
      user = FactoryGirl.create(:user)
      post = FactoryGirl.build(:post, uid: user.uid)
      Services::Mandrill.should_receive(:mail).with(post.campaign.lead, post.campaign.lead_email, user.email, post.campaign.email_submit)
      post.save
    end

    describe 'infinite scroll functionality' do
      before :each do
        @post = FactoryGirl.create(:post)
        @promoted = FactoryGirl.create(:post, campaign_id: @post.campaign.id, promoted: true)
        @scroll = Post.get_scroll(@post.campaign, false, {}, "")[1]
      end

      it 'shows some posts' do
        @scroll.length.should be > 0
      end

      it 'has an image' do
        @scroll.first.image.url(:gallery).should_not be nil
      end

      it 'will show a promoted post' do
        @scroll.should include(@promoted)
      end

      context 'pagination', focus:true do
        before :each do
          @campaign = FactoryGirl.create(:campaign)
          FactoryGirl.create_list(:post, 20, campaign_id: @campaign.id)
          @posts = Post.build_post(@campaign)
        end

        it 'shows 9 results on the first page.' do
          @posts.scrolly.length.should be 9
        end
        it 'shows 9 results on a subsequent page' do
          last_id = Post.order('id DESC').limit(10).last.id
          @posts.scrolly(last_id).length.should be 9
        end
      end
    end

    describe 'filtering' do
      before :each do
        @caliCat = FactoryGirl.create(:post, state: "CA", extras: { :animal_type => 'cat' })
        @campaign = FactoryGirl.create(:campaign)
        add_config(@campaign.path)
      end

      after { remove_config(@campaign.path) }

      it 'filters posts' do
        results = Post.filtered({ campaign_path: @campaign.path, filter: "cats-CA" })
        results.should include(@caliCat)
      end
    end

    describe 'cleaning' do
      it 'strips bad tags from name' do
        new_post = FactoryGirl.create(:post, name: '<b>Spot</b>')
        new_post.name.should eq 'Spot'
      end
      it 'strips bad tags from meme text' do
        new_post = FactoryGirl.create(:post, meme_text: '<b>Meme</b>')
        new_post.meme_text.should eq 'Meme'
      end
    end
  end
end

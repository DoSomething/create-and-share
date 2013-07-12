require 'spec_helper'

describe Post do
  it 'has a valid factory' do
    FactoryGirl.create(:post).should be_valid
  end

  describe 'Model validations' do
    before :each do
      @post = FactoryGirl.build(:post)
    end

    it 'is invalid without name' do
      @post.name = nil
      @post.should_not be_valid
    end

    it 'is invalid without shelter' do
      @post.shelter = nil
      @post.should_not be_valid
    end

    context 'animal type' do
      it 'is invalid without animal_type' do
        @post.animal_type = nil
        @post.should_not be_valid
      end

      it 'is invalid without a correct animal type' do
        @post.animal_type = 'mittens'
        @post.should_not be_valid
      end
    end

    it 'is invalid without city' do
      @post.city = nil
      @post.should_not be_valid
    end

    context 'state' do
      it 'is invalid without state' do
        @post.state = nil
        @post.should_not be_valid
      end
      it 'is invalid with a longer state' do
        @post.state = 'PAX'
        @post.should_not be_valid
      end
      it 'is invalid without a valid state' do
        @post.state = '12'
        @post.should_not be_valid
      end
    end

    it 'is invalid without shelter' do
      @post.shelter = nil
      @post.should_not be_valid
    end

    it 'is invalid without campaign_id' do
      @post.campaign_id = nil
      @post.should_not be_valid
    end

    it 'is invalid without image' do
      @post.image = nil
      @post.should_not be_valid
    end
  end

  describe 'methods' do
    before :each do
      @post = Post
      @real_post = FactoryGirl.create(:post)
      @share = FactoryGirl.create(:share, post_id: @real_post.id)
    end

    it 'has a per page count' do
      @post.per_page.should == 10
    end

    context 'infinite scroll functionality' do
      before :each do
        @scroll = @post.infinite_scroll(@real_post.campaign_id)
      end

      it 'shows some posts' do
        @scroll.length.should be > 0
      end
      it 'has a share count' do
        @scroll.first.real_share_count.to_i.should be > 0
      end
      it 'has an image' do
        @scroll.first.image.url(:gallery).should_not be nil
      end

      context 'pagination' do
        before :each do
          20.times do
            FactoryGirl.create(:post)
          end
        end

        let (:scrolly) { @scroll.scrolly }

        it 'Shows 9 results on the first page.' do
          scrolly.length.should be 9
        end
        it 'shows 9  results on a subsequent page' do
          last_id = Post.order('id DESC').limit(10).last.id
          scrolly = @scroll.scrolly(last_id)

          scrolly.length.should be 9
        end
      end
    end

    context 'cleaning' do
      it 'strips bad tags from name' do
        new_post = FactoryGirl.create(:post, name: '<b>Spot</b>')
        new_post.name.should eq 'Spot'
      end
      it 'strips bad tags from shelter' do
        new_post = FactoryGirl.create(:post, shelter: '<b>Shelter</b>')
        new_post.shelter.should eq 'Shelter'
      end
      it 'strips bad tags from meme text' do
        new_post = FactoryGirl.create(:post, meme_text: '<b>Meme</b>')
        new_post.meme_text.should eq 'Meme'
      end
    end
  end
end

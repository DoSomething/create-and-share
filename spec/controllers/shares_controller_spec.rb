require 'spec_helper'

describe SharesController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:campaign) { FactoryGirl.create(:campaign, path: "picsforpets") }
  let(:session) { { drupal_user_id: user.uid, drupal_user_role: { test: 'authenticated user', blah: 'administrator' } } }
  

  before :each do
    @post = FactoryGirl.create(:post, campaign_id: campaign.id)
    attributes = FactoryGirl.attributes_for(:share)
    attributes[:post_id] = @post.id
    @params = { share: attributes, new_count: 1, campaign_path: campaign.path }
  end

  describe "POST #create" do
    it "creates a new share" do
      expect { post :create, @params, session }.to change(Share, :count).by(1)
    end

    it "increases share count for that post" do
      expect { post :create, @params, session }.to change { Post.find(@params[:share][:post_id]).share_count }.by(1)
    end
  end

  describe "popups" do
    context "action count does not correspond to a popup" do
      it 'assigns a blank string to popup' do
        User.any_instance.stub(:action_count).and_return(0)
        xhr :post, :create, @params, session
        JSON.parse(response.body)["popup"].should be_blank
      end
    end

    context "action count does correspond to a popup" do
      it 'assigns "test" to popup if action count is 5' do
        User.any_instance.stub(:action_count).and_return(5)
        xhr :post, :create, @params, session
        JSON.parse(response.body)["popup"].should eq "test"
      end
    end
  end
end
require 'spec_helper'

describe PostsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:campaign) { FactoryGirl.create(:campaign, path: "picsforpets") }
  let(:session) { { drupal_user_id: user.uid, drupal_user_role: { test: 'authenticated user', blah: 'administrator' } } }

  before { @post = FactoryGirl.create(:post, campaign_id: campaign.id) }

  describe 'GET #index' do
    it 'shows index' do
      FactoryGirl.create(:promo, campaign_id: campaign.id)

      get :index, { :campaign_path => campaign.path }, session

      expect(assigns(:promoted)).to eq Post.find_by_promoted(true)
      expect(assigns(:posts)).to include(@post)
      expect(assigns(:count)).to eq 2
      expect(response).to render_template 'index'
    end
  end

  describe 'GET #show' do
    it 'assigns post' do
      get :show, { :campaign_path => campaign.path, :id => @post.id }, session

      expect(assigns(:post)).to eq @post
    end
  end

  describe 'GET #new' do
    it 'assigns a new post' do
      get :new, { :campaign_path => campaign.path }, session
      expect(assigns(:post)).to be_a_new(Post)
    end
  end

  describe "GET #edit" do
    it "assigns the requested post" do
      get :edit, { :campaign_path => campaign.path, :id => @post.id }, session
      expect(assigns(:post)).to eq(@post)
    end
  end

  describe "POST methods" do
    before :each do
      @attributes = FactoryGirl.attributes_for(:post)
      @attributes[:campaign_id] = campaign.id
    end

    describe "POST #create" do
      describe "with valid params" do
        it "creates a new post" do
          expect { post :create, {:post => @attributes}, session }.to change(Post, :count).by(1)
        end

        it "assigns a newly created post" do
          post :create, {:post => @attributes}, session

          assigns(:post).should be_a(Post)
          assigns(:post).should be_persisted
        end

        it "redirects to the created post" do
          post :create, {:post => @attributes }, session

          response.should redirect_to show_post_path(assigns(:post), :campaign_path => campaign.path)
        end
      end

      describe "with invalid params" do
        before { Post.any_instance.stub(:save).and_return(false) }

        it "assigns a newly created but unsaved post" do
          # Trigger the behavior that occurs when invalid params are submitted
          post :create, {:post => { "meme_text" => "invalid value" }}, session
          assigns(:post).should be_a_new(Post)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          post :create, {:post => { "meme_text" => "invalid value" }}, session
          response.should render_template("new")
        end
      end
    end

    describe "PUT #update" do
      describe "with valid params" do
        it "updates the requested post" do
          Post.any_instance.should_receive(:update_attributes).with({ "meme_text" => "hmu" })
          put :update, {:id => @post.id, :post => { "meme_text" => "hmu" }}, session
        end

        it "assigns the requested post" do
          put :update, {:id => @post.id, :post => @attributes}, session
          assigns(:post).should eq @post
        end

        it "redirects to the post" do
          put :update, {:id => @post.id, :post => @attributes}, session
          response.should redirect_to show_post_path(assigns(:post), :campaign_path => campaign.path)
        end
      end

      describe "with invalid params" do
        before :each do
          Post.any_instance.stub(:save).and_return(false)
          put :update, {:id => @post.id, :post => { meme_text: "some jaunt" }}, session
        end

        it "assigns the post" do
          # Trigger the behavior that occurs when invalid params are submitted
          assigns(:post).should eq @post
        end

        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          response.should render_template("edit")
        end
      end
    end
  end
  
  describe "DELETE destroy" do
    it "destroys the requested post" do
      expect { delete :destroy, { :id => @post.id, :campaign_path => campaign.path }, session }.to change(Post, :count).by(-1)
    end

    it "redirects to the post wall" do
      delete :destroy, { :id => @post.id, :campaign_path => campaign.path }, session
      response.should redirect_to posts_url
    end
  end

  describe "flagging" do
    it 'flags a post' do
      request.env['HTTP_REFERER'] = root_path(:campaign_path => campaign.path)
      expect { get :flag, { id: @post.id }, session }.to change { Post.find(@post.id).flagged }.to(true)
    end
  end

  describe "vanity" do
    it "has named urls for promoted pets" do
      promoted = FactoryGirl.create(:promo, campaign_id: campaign.id)
      get :vanity, { campaign_path: campaign.path, vanity: promoted.name }, session
      assigns(:post).should eq promoted
    end

    it "does not have named urls for unpromoted pets" do
      get :vanity, { campaign_path: campaign.path, vanity: @post.name }, session
      response.should redirect_to root_path(campaign_path: campaign.path)
    end
  end

  describe 'filter' do
    before :each do
      @caliCat = FactoryGirl.create(:post, state: "CA", extras: { :animal_type => 'cat' }, campaign_id: campaign.id)
      CreateAndShare::Application.config.filters = { campaign.path => { ":atype-:state" => { "constraints" => { ":atype" => "(?<atype>cat|dog|other)s?", ":state" => "(?<state>[A-Z]{2})" }, "where" => { "animal_type" => "atype", "state" => "state" } } } }
    end

    describe 'filters posts' do
      specify 'includes' do
        get :filter, { campaign_path: campaign.path, filter: "cats-CA" }, session
        assigns(:posts).should include(@caliCat)
      end

      specify 'does not includes' do
        get :filter, { campaign_path: campaign.path, filter: "cats-VA" }, session
        assigns(:posts).should_not include(@caliCat)
      end
    end

    it 'redirects to root if no filters' do
      CreateAndShare::Application.config.filters[campaign.path] = nil
      get :filter, { campaign_path: campaign.path, filter: "cats-VA" }, session
      expect(response).to redirect_to root_path(campaign_path: campaign.path)
    end

    it 'redirects to root if there is an error in Post.filtered' do
      Post.stub(:filtered).and_raise("well, shit")
      get :filter, { campaign_path: campaign.path, filter: "cats-VA" }, session
      expect(response).to redirect_to root_path(campaign_path: campaign.path)
    end
  end

  describe "extras" do
    describe "mine" do
      before :each do
        @mine = FactoryGirl.create(:post, campaign_id: campaign.id, uid: user.uid)
        @notMine = FactoryGirl.create(:post, campaign_id: campaign.id, uid: 9999999)
        get :extras, { campaign_path: campaign.path, run: "mine" }, session
      end

      it 'displays users posts' do
        assigns(:posts).should include(@mine)
      end

      it 'does not display other posts' do
        assigns(:posts).should_not include(@notMine)
      end
    end

    describe "featured" do
      before :each do
        @promoted = FactoryGirl.create(:promo, campaign_id: campaign.id)
        @notPromoted = FactoryGirl.create(:post, campaign_id: campaign.id)
        get :extras, { campaign_path: campaign.path, run: "featured" }, session
      end

      it 'displays promoted pets' do
        assigns(:posts).should include(@promoted)
      end

      it 'does not display regular pets' do
        assigns(:posts).should_not include(@notPromoted)
      end
    end
  end
end
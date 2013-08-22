require 'spec_helper'

describe CampaignsController, :type => :controller do
  let(:valid_attributes) { FactoryGirl.attributes_for(:campaign) }
  let(:user) { FactoryGirl.create(:user) }
  let(:valid_session) { { drupal_user_id: user.uid, drupal_user_role: { test: 'authenticated user', blah: 'administrator' } } }
  let(:invalid_session) { { drupal_user_id: user.uid, drupal_user_role: { test: 'authenticated user' } } }

  describe "GET index" do
    it "assigns all campaigns as @campaigns" do
      campaign = FactoryGirl.create(:campaign)
      get :index
      assigns(:campaigns).should eq([campaign])
    end
  end

  describe "GET #new" do
    it 'denies you if you are unauthorized' do
      get :new
      response.should redirect_to '/login'
      response.status.should eq 302
    end

    it "assigns a new campaign as @campaign" do
      get :new, {}, valid_session
      assigns(:campaign).should be_a_new(Campaign)
    end
  end

  describe "GET edit" do
    it 'denies you if you are unauthorized' do
      get :new
      response.should redirect_to '/login'
      response.status.should eq 302
    end
    it "assigns the requested campaign as @campaign" do
      campaign = FactoryGirl.create(:campaign)
      get :edit, { :id => campaign.to_param }, valid_session
      assigns(:campaign).should eq(campaign)
    end
  end

  describe "POST create" do
    it 'denies you if you are unauthorized' do
      post :create, { :campaign => valid_attributes }, invalid_session
      response.status.should eq 500
    end

    describe "with valid params" do
      it "creates a new Campaign" do
        expect { post :create, {:campaign => valid_attributes}, valid_session }.to change(Campaign, :count).by(1)
      end

      it "assigns a newly created campaign as @campaign" do
        post :create, {:campaign => valid_attributes}, valid_session
        assigns(:campaign).should be_a(Campaign)
        assigns(:campaign).should be_persisted
      end

      it "redirects to the created campaign" do
        post :create, {:campaign => valid_attributes}, valid_session
        response.should redirect_to('/' + Campaign.last.path)
      end
    end

    describe "with invalid params" do
      before { Campaign.any_instance.stub(:save).and_return(false) }

      it "assigns a newly created but unsaved campaign as @campaign" do
        # Trigger the behavior that occurs when invalid params are submitted
        post :create, {:campaign => { "title" => "invalid value" }}, valid_session
        assigns(:campaign).should be_a_new(Campaign)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        post :create, {:campaign => { "title" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    it 'denies you if you are unauthorized' do
      post :create, { :campaign => valid_attributes }, invalid_session
      response.status.should eq 500
    end

    describe "with valid params" do
      let(:factory_attrs) { FactoryGirl.attributes_for(:campaign) }
      let(:campaign) { Campaign.create!(factory_attrs) }

      it "updates the requested campaign" do
        # Assuming there are no other campaigns in the database, this
        # specifies that the Campaign created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Campaign.any_instance.should_receive(:update_attributes).with({ "title" => "MyString" })
        put :update, {:id => campaign.to_param, :campaign => { "title" => "MyString" }}, valid_session
      end

      it "assigns the requested campaign as @campaign" do
        put :update, {:id => campaign.to_param, :campaign => factory_attrs }, valid_session
        assigns(:campaign).should eq campaign
      end

      it "redirects to the campaign" do
        put :update, { :id => campaign.to_param, :campaign => factory_attrs }, valid_session
        response.should redirect_to(root_path(:campaign_path => campaign.path))
      end
    end

    describe "with invalid params" do
      before :each do
        @campaign = FactoryGirl.create(:campaign)
        Campaign.any_instance.stub(:save).and_return(false)
        put :update, {:id => @campaign.to_param, :campaign => { "title" => "invalid value" }}, valid_session
      end

      it "assigns the campaign as @campaign" do
        # Trigger the behavior that occurs when invalid params are submitted!
        assigns(:campaign).should eq @campaign
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it 'denies you if you are unauthorized' do
      post :create, { :campaign => valid_attributes }, invalid_session
      response.status.should eq 500
    end

    it "destroys the requested campaign" do
      campaign = FactoryGirl.create(:campaign)
      expect {
        delete :destroy, {:id => campaign.to_param}, valid_session
      }.to change(Campaign, :count).by(-1)
    end

    it "redirects to the campaigns list" do
      campaign = FactoryGirl.create(:campaign)
      delete :destroy, {:id => campaign.to_param}, valid_session
      response.should redirect_to(campaigns_url)
    end
  end
end

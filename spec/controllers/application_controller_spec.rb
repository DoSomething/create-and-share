require 'spec_helper'

describe ApplicationController do
  controller do
    before_filter :get_campaign, :find_view_path, only: [:index]
    def index
      @view_paths = view_paths.count
      @legible = make_legible
      @submitted = already_submitted?
      @authenticated = authenticated?
      @admin = admin?
      render :nothing => true
    end

    before_filter :is_authenticated, only: [:new]
    def new
      render :nothing => true
    end

    before_filter :is_not_authenticated, only: [:edit]
    def edit
      render :nothing => true
    end

    before_filter :admin, only: [:destroy]
    def destroy
      render :nothing => true
    end
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:campaign) { FactoryGirl.create(:campaign) }
  let(:session) { { drupal_user_id: user.uid, drupal_user_role: { test: 'authenticated user', blah: 'administrator' } } }

  describe 'authorization' do
    before { @session = { drupal_user_role: {} } }
    describe 'is authenticated' do
      before { @session[:drupal_user_role][:test] = "authenticated user" }

      specify 'without campaign' do
        get :new, {}, @session
        expect { response }.to redirect_to '/'
      end

      specify 'with campaign' do
        get :new, { campaign_path: campaign.path }, @session
        expect { response }.to redirect_to root_path(campaign_path: campaign.path)
      end

      specify 'not authenticated' do
        @session[:drupal_user_role][:test] = "has to login"
        get :new, { campaign_path: campaign.path }, @session
        response.status.should_not eq 302
      end
    end

    describe 'is not authenticated' do
      before { routes.draw { get "edit" => "anonymous#edit" } }

      specify 'without campaign' do
        get :edit, {}, @session
        expect { response }.to redirect_to '/login'
      end

      specify 'with campaign' do
        get :edit, { campaign_path: campaign.path }, @session
        expect { response }.to redirect_to "/#{campaign.path}/login"
      end

      specify 'authenticated' do
        @session[:drupal_user_role][:test] = "authenticated user"
        get :edit, { campaign_path: campaign.path }, @session
        response.status.should_not eq 302
      end
    end

    describe 'is admin' do
      before { routes.draw { get "destroy" => "anonymous#destroy" } }

      specify 'as an admin' do
        @session[:drupal_user_role][:test] = "administrator"
        delete :destroy, {}, @session
        response.status.should_not eq 302
      end

      specify 'as an authenticated user' do
        @session[:drupal_user_role][:test] = "authenticated user"
        delete :destroy, {}, @session
        expect { response }.to redirect_to "/login"
      end

      specify 'as no one' do
        delete :destroy, {}, @session
        expect { response }.to redirect_to "/login"
      end
    end
  end

  describe 'authorization helpers' do
    before { @session = { drupal_user_role: {} } }
    describe 'checks authenticated' do
      it 'is authenticated' do
        @session[:drupal_user_role][:test] = "authenticated user"
        get :index, {}, @session
        assigns(:authenticated).should be_true
      end

      it 'is not authenticated' do
        get :index, {}, @session
        assigns(:authenticated).should be_false
      end
    end

    describe 'checks admin' do
      it 'is admin' do
        @session[:drupal_user_role][:test] = "administrator"
        get :index, {}, @session
        assigns(:admin).should be_true
      end

      it 'is not admin' do
        @session[:drupal_user_role][:test] = "authenticated user"
        get :index, {}, @session
        assigns(:admin).should be_false
      end
    end
  end

  it 'gets campaign' do
    campaign = FactoryGirl.create(:campaign)
    get :index, campaign_path: campaign.path

    assigns(:campaign).should eq campaign
  end

  describe 'makes legible' do
    it 'featured' do
      get :index, filter: "featured"
      assigns(:legible).should eq "any featured posts yet"
    end

    it 'mine' do
      get :index, filter: "mine"
      assigns(:legible).should eq "anything by you yet"
    end

    it 'other' do
      get :index, filter: "lalala"
      assigns(:legible).should eq "anything here"
    end
  end

  describe 'checks for submission' do
    context 'has posts' do
      before { FactoryGirl.create(:post, campaign_id: campaign.id) }
      it 'has posts in one campaign' do
        get :index, { campaign_path: campaign.path }, session
        assigns(:submitted).should eq true
      end
      it 'does not have posts in another campaign' do
        other = FactoryGirl.create(:campaign, path: "other")
        get :index, { campaign_path: other.path }, session
        assigns(:submitted).should eq false
      end
    end

    it 'no posts' do
      get :index, { campaign_path: campaign.path }, session
      assigns(:submitted).should eq false
    end
  end

  describe 'getting proper view paths' do
    it 'with a campaign' do
      get :index, { campaign_path: campaign.path }
      assigns(:view_paths).should eq 2
    end

    it 'without a campaign' do
      get :index
      assigns(:view_paths).should eq 1
    end
  end
end
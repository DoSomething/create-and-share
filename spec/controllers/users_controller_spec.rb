require 'spec_helper'

describe UsersController, :type => :controller do
  let(:campaign) { FactoryGirl.create(:campaign) }
  before :each do
    @user = FactoryGirl.create(:user)
    @session = { drupal_user_id: @user.uid, drupal_user_role: { test: 'authenticated user', blah: 'administrator' } }
    Services::MailChimp.stub(:subscribe)
    Services::Mandrill.stub(:mail)
    Services::MobileCommons.stub(:subscribe)
  end

  describe 'intent' do
    it 'redirects to start' do
      @user.participations.create(intent: false, campaign_id: campaign.id)
      get :intent, { :campaign_path => campaign.path }, @session
      expect(response).to redirect_to start_path(campaign_path: campaign.path)
    end

    it 'saves the intent' do
      get :participation, { :campaign_path => campaign.path }, @session
      expect { get :intent, { :campaign_path => campaign.path }, @session }.to change { @user.participations.where(campaign_id: campaign.id).first.intent }.from(false).to(true)
    end
  end

  describe 'participation' do
    describe 'source redirection' do
      it 'redirects to original source' do
        session = @session
        session[:source] = "/#{campaign.path}/submit"
        get :participation, { :campaign_path => campaign.path }, session

        expect(response).to redirect_to "/#{campaign.path}/submit"
      end

      it 'redirects to root if no source' do
        get :participation, { :campaign_path => campaign.path }, @session

        expect(response).to redirect_to root_path(campaign_path: campaign.path)
      end
    end

    describe 'saves a participation' do
      context 'no participation yet' do
        it 'creates a participation' do
          expect { get :participation, { :campaign_path => campaign.path }, @session }.to change { Participation.all.count }.by(1)
        end

        it 'associates the participation with the user' do
          expect { get :participation, { :campaign_path => campaign.path }, @session }.to change { @user.participations.count }.by(1)
        end

        it 'associates the participation with the campaign' do
          expect { get :participation, { :campaign_path => campaign.path }, @session }.to change { campaign.participations.count }.by(1)
        end
      end

      context 'already participated' do
        before :each do
          @user.participations.create(intent: false, campaign_id: campaign.id)
        end

        it 'does not create a participation' do
          expect { get :participation, { :campaign_path => campaign.path }, @session }.not_to change { Participation.all.count }
        end
      end
    end
  end
end
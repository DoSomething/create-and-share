class CampaignsController < ApplicationController
  layout 'admin', :except => [:show]
  # We can skip this for testing purposes.
  # @TODO: Change this later to honor proper auth.
  if !Rails.env.test?
    before_filter :admin, :except => [:index]
  end

  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Rails.cache.fetch 'campaign-list' do
      Campaign.order('created_at DESC').all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @campaigns }
    end
  end

  # GET /campaigns/new
  # GET /campaigns/new.json
  def new
    @campaign = Campaign.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @campaign }
    end
  end

  # GET /campaigns/1/edit
  def edit
    @campaign = Campaign.find(params[:id])
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(params[:campaign])

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to '/' + @campaign.path, notice: 'Campaign was successfully created.' }
        format.json { render json: @campaign, status: :created, location: @campaign }
      else
        format.html { render action: "new" }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.json
  def update
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        format.html { redirect_to root_path(:campaign_path => @campaign.path), notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy

    respond_to do |format|
      format.html { redirect_to campaigns_url }
      format.json { head :no_content }
    end
  end

  before_filter :get_campaign, only: [:popups]
  # GET /:campaign/popups/:popup
  def popups
    render Rails.root.to_s + "/app/views/campaigns/#{@campaign.path}/popups/#{params[:popup]}"
  end
end

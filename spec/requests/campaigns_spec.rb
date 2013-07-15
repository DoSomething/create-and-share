require 'spec_helper'

describe "Campaigns" do
  describe "GET /campaigns" do
    it "redirects to the index page" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get campaigns_path
      response.status.should be(301)
      request.should redirect_to('/')
    end
  end
end

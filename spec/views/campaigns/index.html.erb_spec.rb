require 'spec_helper'

describe "campaigns/index" do
  before(:each) do
    assign(:campaigns, [
      stub_model(Campaign,
        :title => "Title",
        :path => "Path",
        :lead => "Lead",
        :lead_email => "Lead Email",
        :developers => "Developers",
        :description => "Campaign",
      ),
      stub_model(Campaign,
        :title => "Title",
        :path => "Path",
        :lead => "Lead",
        :lead_email => "Lead Email",
        :developers => "Developers",
        :description => "Campaign",
      )
    ])
  end

  it "renders a list of campaigns" do
    render
    assert_select ".campaign a>h2", :text => "Title".to_s, :count => 2
    assert_select ".campaign>p", :text => "Campaign".to_s, :count => 2
  end
end

require 'spec_helper'

describe "campaigns/index" do
  before(:each) do
    assign(:campaigns, [
      stub_model(Campaign,
        :title => "Title",
        :path => "Path",
        :lead => "Lead",
        :lead_email => "Lead Email",
        :developers => "Developers"
      ),
      stub_model(Campaign,
        :title => "Title",
        :path => "Path",
        :lead => "Lead",
        :lead_email => "Lead Email",
        :developers => "Developers"
      )
    ])
  end

  it "renders a list of campaigns" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Path".to_s, :count => 2
    assert_select "tr>td", :text => "Lead".to_s, :count => 2
    assert_select "tr>td", :text => "Lead Email".to_s, :count => 2
    assert_select "tr>td", :text => "Developers".to_s, :count => 2
  end
end

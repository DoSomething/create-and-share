require 'spec_helper'

describe "campaigns/show" do
  before(:each) do
    @campaign = assign(:campaign, stub_model(Campaign,
      :title => "Title",
      :path => "Path",
      :lead => "Lead",
      :lead_email => "Lead Email",
      :developers => "Developers"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Path/)
    rendered.should match(/Lead/)
    rendered.should match(/Lead Email/)
    rendered.should match(/Developers/)
  end
end

require 'spec_helper'

describe "campaigns/edit" do
  before(:each) do
    @campaign = assign(:campaign, stub_model(Campaign,
      :title => "MyString",
      :path => "MyString",
      :lead => "MyString",
      :lead_email => "MyString",
      :developers => "MyString"
    ))
  end

  it "renders the edit campaign form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", campaign_path(@campaign), "post" do
      assert_select "input#campaign_title[name=?]", "campaign[title]"
      assert_select "input#campaign_path[name=?]", "campaign[path]"
      assert_select "input#campaign_lead[name=?]", "campaign[lead]"
      assert_select "input#campaign_lead_email[name=?]", "campaign[lead_email]"
      assert_select "input#campaign_developers[name=?]", "campaign[developers]"
    end
  end
end

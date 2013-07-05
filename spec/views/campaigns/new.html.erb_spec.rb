require 'spec_helper'

describe "campaigns/new" do
  before(:each) do
    assign(:campaign, stub_model(Campaign,
      :title => "MyString",
      :path => "MyString",
      :lead => "MyString",
      :lead_email => "MyString",
      :developers => "MyString"
    ).as_new_record)
  end

  it "renders new campaign form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", campaigns_path, "post" do
      assert_select "input#campaign_title[name=?]", "campaign[title]"
      assert_select "input#campaign_path[name=?]", "campaign[path]"
      assert_select "input#campaign_lead[name=?]", "campaign[lead]"
      assert_select "input#campaign_lead_email[name=?]", "campaign[lead_email]"
      assert_select "input#campaign_developers[name=?]", "campaign[developers]"
    end
  end
end

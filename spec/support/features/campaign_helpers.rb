def fill_campaign_form
  campaign = FactoryGirl.build(:campaign)
  fill_in 'campaign_title', with: campaign.title
  select campaign.start_date.strftime("%B"), from: 'campaign_start_date_2i'
  select campaign.start_date.strftime("%e").strip, from: 'campaign_start_date_3i'
  select campaign.start_date.strftime("%Y"), from: 'campaign_start_date_1i'
  select campaign.end_date.strftime("%B"), from: 'campaign_end_date_2i'
  select campaign.end_date.strftime("%e").strip, from: 'campaign_end_date_3i'
  select campaign.end_date.strftime("%Y"), from: 'campaign_end_date_1i'
  fill_in 'campaign_path', with: campaign.path
  fill_in 'campaign_lead', with: campaign.lead
  fill_in 'campaign_lead_email', with: campaign.lead_email
  fill_in 'campaign_developers', with: campaign.developers
  fill_in 'campaign_mailchimp', with: campaign.mailchimp
  fill_in 'campaign_email_signup', with: campaign.email_signup
  fill_in 'campaign_email_submit', with: campaign.email_submit
  fill_in 'campaign_mobile_commons', with: campaign.mobile_commons
  fill_in 'campaign_description', with: campaign.description
  attach_file 'campaign_image', Rails.root.to_s + '/spec/mocks/ruby.png'
  if campaign.meme
    check 'campaign_meme'
    fill_in 'campaign_meme_header', with: campaign.meme_header
  end
  if campaign.gated
    select 'Gate entire campaign', from: 'campaign_gated'
  end
  fill_in 'campaign_stat_frequency', with: campaign.stat_frequency
  campaign
end

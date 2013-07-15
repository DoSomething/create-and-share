# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :campaign do
    title "Pics for Pets"
    start_date "2013-07-05 11:47:46"
    end_date "2015-07-05 11:47:46"
    path "picsforpets"
    lead "Test user"
    lead_email "test+user@dosomething.org"
    developers "mchittenden@dosomething.org"
    description "Pics for pets is a campaign about pictures of pets."
    image nil
    gated true
  end
end

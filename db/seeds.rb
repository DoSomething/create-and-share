# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Campaign.create!({
  title: 'Fed Up',
  start_date: '2013-08-12 16:05:00',
  end_date: '2016-08-12 16:05:00',
  path: 'fedup',
  lead: 'Farah',
  lead_email: 'lunch@dosomething.org',
  developers: 'mchittenden@dosomething.org, mwatson@dosomething.org',
  gated: 'submit',
  description: "Push for better quality lunch food with Fed Up.  Schools around the nation are serving students inedible junk and we'd like to change that.  Upload a picture your lunch, rate it, and share it with your friends.",
  image: File.new(Rails.root + 'app/assets/images/campaigns/lunch/sandwich.jpg'),
  mailchimp: "PicsforPets2013",
  mobile_commons: "158551",
  email_submit: "PicsforPets_2013_Reportback",
  email_signup: "PicsforPets_2013_Reportback",
  meme_header: "",
  meme: false,
  paged_form: true,
  has_school_field: true,
  facebook: 'mine',
  stat_frequency: 2
})

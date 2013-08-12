# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Campaign.create({
  title: 'Project Lunch',
  start_date: '2013-08-12 16:05:00',
  end_date: '2016-08-12 16:05:00',
  path: 'lunch',
  lead: 'Farah',
  lead_email: 'fshake@dosomething.org',
  developers: 'mchittenden@dosomething.org, mwatson@dosomething.org',
  gated: true,
  description: "Push for better quality lunch food with Project Lunch.  Schools around the nation are serving students inedible junk and we'd like to change that.  Upload a picture your lunch, rate it, and share it with your friends.",
  image: File.new(Rails.root + 'app/assets/images/campaigns/lunch/sandwich.jpg'),
  mailchimp: "PicsforPets2013",
  mobile_commons: "158551",
  email_submit: "PicsforPets_2013_Reportback",
  email_signup: "PicsforPets_2013_Reportback",
  meme_header: "",
  meme: false
})

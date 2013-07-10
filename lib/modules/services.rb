require 'httparty'
require 'gibbon'
require 'mailchimp'

module Services
  # Login / out / register methods
  module Auth
    include HTTParty
    base_uri 'www.dosomething.org:443' # Force HTTPS connection via port 443

    def self.login(username, password)
      post('/rest/user/login.json?' + Time.now.to_i.to_s, :body => { :username => CGI.escape(username), :password => CGI.escape(password) })
    end

    def self.logout(username, password)
      post('/rest/user/logout.json?' + Time.now.to_i.to_s, :body => { :username => CGI.escape(username), :password => CGI.escape(password) })
    end

    def self.authenticate(session, uid, roles={})
      session[:drupal_user_id]      = uid
      session[:drupal_user_role]    = roles
    end

    def self.register(password, email, first, last, cell, month, day, year)
      birthday = "#{month}/#{day}/#{year}"
      post('/rest/user/register.json?' + Time.now.to_i.to_s, :body => {
        'profile_main[field_user_first_name][und][0][value]' => first,
        'profile_main[field_user_last_name][und][0][value]' => last,
        'mail' => email,
        'profile_main[field_user_mobile][und][0][value]' => cell,
        'pass'  => password,
        'profile_main[field_user_birthday][und][0][value][date]' => birthday,
        'name'  =>  email, # Set username equal to email
        'profile_main[field_user_official_rules][und]' => 1 # Pass user's acceptance of the official rules
      })
    end

    def self.check_exists(email)
      if !email.nil?
        get('/ruby/users/' + email + '?' + Time.now.to_i.to_s)
      end
    end

    def self.check_admin(email)
      if !email.nil?
        get ('/ruby/users/is_admin/' + email + '?' + Time.now.to_i.to_s)
      end
    end
  end

  # MailChimp (email) methods
  module MailChimp
    @mc = Gibbon.new('cdd0ad8955001739ec42519956312bee-us4')
    def self.subscribe(email, campaign)
      @groups = {
        'PicsforPets2013' => 10621
      }

      @gid = Rails.cache.fetch 'mailchimp-group-' + campaign do
        gbit = ''

        if !@groups[campaign].nil?
          gbit = @groups[campaign]
        end

        gbit
      end

      @campaign = campaign
      mv = { 'GROUPINGS' => { 0 => { 'id' => @gid, 'groups' => campaign } } }
      r = @mc.list_subscribe({
      	:id => 'f2fab1dfd4',
      	:email_address => email,
      	:merge_vars => mv,
      	:email_type => 'html',
      	:double_optin => false,
      	:update_existing => true,
      	:replace_interests => false,
      })
    end
  end

  # Mobile Commons (txt messaging) methods
  module MobileCommons
    include HTTParty
    base_uri 'dosomething.mcommons.com'

    def self.subscribe(mobile, opt_in_path)
      post('/profiles/join', :body => { 'person[phone]' => mobile, 'opt_in_path[]' => opt_in_path })
    end
  end

  module Mandrill
    include Mailchimp

    def self.mail(email, template, subject)
      @mandrill = Mailchimp::Mandrill.new(ENV['MANDRILL_APIKEY'])
      response = @mandrill.messages_send_template({
       :template_name => template,
       :template_content => [
         {
           :name => "Friend",
         }
       ],
       :message => {
         :from_name=> "Hilary at DoSomething.org",
         :from_email => "animals@dosomething.org",
         :subject => subject,
         :to => [
           {
             :email=> email,
             :name => "friend"
           }
         ],
         :auto_html => true,
         :merge_vars => [
           {
             :rcpt => email,
             :vars => [
                {
                  :name => "SUBJECT",
                  :content => subject
                }
             ]
           }
         ]
        }
      })
    end 
  end
end

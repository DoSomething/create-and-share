class User < ActiveRecord::Base
  attr_accessible :email, :fbid, :uid, :is_admin, :mobile
  cattr_accessor :campaign

  has_many :campaigns, through: :participations
  has_many :participations, dependent: :destroy

  acts_as_voter

  include Services

  # checks if a user with the given email exists in the DoSomething drupal database
  def self.exists?(email)
    if email.nil?
      false
    elsif !Services::Auth.check_exists(email).first.nil? || (email.index('@').nil? && email.gsub(/[^0-9]/, '').length == 10)
      true
    else
      false
    end
  end

  # creates a new user with the given parameters in the DoSomething drupal database
  def self.register(password, email, fbid, first, last, cell, birthday)
    bday = Date.strptime(birthday, '%m/%d/%Y')
    response = Services::Auth.register(password, email, first, last, cell, bday.month, bday.day, bday.year)
    if response.code == 200 && response.kind_of?(Hash)
      return true
    else
      return false
    end
  end

  # logs in a user with the given parameters and creates an entry in the rails database if one doesn't exist already
  def self.login(campaign, session, username, password, cell, fbid)
    if fbid != 0 # if logging in with Facebook
      uid = Services::Auth.check_admin(username).first
      if uid
        uid = uid['uid']
        roles = { 1 => 'administrator', 2 => 'authenticated user' }
      else
        uid = Services::Auth.check_exists(username).first
        if uid
          uid = uid['uid']
          roles = { 1 => 'authenticated user'}
        else
          return false
        end
      end
    else # if logging in through drupal
      response = Services::Auth.login(username, password)
      if response.code == 200 && response.kind_of?(Hash)
        uid = response['user']['uid']
        roles = response['user']['roles']
        if !response["profile"]["field_user_mobile"].empty?
          mobile = response["profile"]["field_user_mobile"]["und"][0]["value"]
        end
      else
        return false
      end
    end

    user = User.find_by_uid(uid)
    if !user # creates a new user if he/she isn't already in the database
      user = User.new(:uid => uid, :fbid => fbid, :email => username, :mobile => mobile, :is_admin => roles.values.include?('administrator'))
    elsif fbid != 0 # adds a fbid if they are logging in with facebook for the first time
      ### UPDATE TO EDIT FACEBOOK ON DRUPAL AS WELL ###
      user.fbid = fbid
    end
    user.save

    # set up session for current user
    session[:drupal_user_id] = uid
    session[:drupal_user_role] = roles
    return true
  end

  # Sends MailChimp / Mobile Commons messages to a user.
  #
  # @param string email
  #   The email to send the message to.
  # @param string mobile
  #   A valid phone number to send a txt to.
  ##
  def handle_mc(campaign)
    if !self.email.nil? && email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
      if !campaign.mailchimp.nil?
        logger.info "Sending mailchimp (#{campaign.mailchimp}) email to (#{self.email})"
        Services::MailChimp.subscribe(self.email, campaign.mailchimp)
      end
      if !campaign.email_signup.nil?
        logger.info "Sending mandrill (#{campaign.email_signup}) email to (#{self.email})"
        Services::Mandrill.mail(campaign.lead, campaign.lead_email, self.email, campaign.email_signup)
      end
    end

    if !self.mobile.nil?
      if !campaign.mobile_commons.nil?
        logger.info "Sending mobile commons (#{campaign.mobile_commons}) text to (#{self.mobile})"
        Services::MobileCommons.subscribe(self.mobile, campaign.mobile_commons)
      end
    end
  end
end

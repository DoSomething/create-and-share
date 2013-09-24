class User < ActiveRecord::Base
  attr_accessible :email, :fbid, :uid, :is_admin, :mobile, :signup_type
  cattr_accessor :campaign

  has_many :campaigns, through: :participations
  has_many :participations, dependent: :destroy
  has_many :posts
  has_many :shares, foreign_key: :uid, primary_key: :uid

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

  # Creates a new user in the Drupal database with the given information.
  #
  # @param [String] password
  #   The user's password.
  # @param [String] email
  #   The user's email address.
  # @param [Fixnum] fbid
  #   The user's (potential) Facebook ID.
  # @param [String] first
  #   The user's first name, if applicable.
  # @param [String] last
  #   The user's last name, if applicable.
  # @param [String] cell
  #    The user's cell phone number, if applicable.
  # @param [String] birthday
  #    The user's birthday.
  def self.register(password, email, fbid, first, last, cell, birthday)
    begin
      bday = Date.strptime(birthday, '%m/%d/%Y')
      response = Services::Auth.register(password, email, first, last, cell, bday.month, bday.day, bday.year)
      if response.code == 200 && response.kind_of?(Hash)
        return true
      else
        return false
      end
    rescue
      return false
    end
  end

  # logs in a user with the given parameters and creates an entry in the rails database if one doesn't exist already
  def self.login(registered, campaign, session, username, password, cell, fbid)
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
      user = User.new(:uid => uid, :fbid => fbid, :email => username, :mobile => mobile, :is_admin => roles.values.include?('administrator'), :signup_type => (registered ? 'new' : 'exists'))
    elsif fbid != 0 # adds a fbid if they are logging in with facebook for the first time
      ### UPDATE TO EDIT FACEBOOK ON DRUPAL AS WELL ###
      user.fbid = fbid
    end
    user.save

    if Rails.env.test?
      # Allows us to fake administrator priveleges in tests
      if user && user.is_admin == true && !roles.values.include?('administrator')
        roles[99] = 'administrator'
      end
    end

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
        begin
          Services::MailChimp.subscribe(self.email, campaign.mailchimp)
        rescue
          # MailChimp sometimes throws an exception here.  There's not much we can do about it.
        end
      end
      if !campaign.email_signup.nil?
        logger.info "Sending mandrill (#{campaign.email_signup}) email to (#{self.email})"
        begin
          Services::Mandrill.mail(campaign.lead, campaign.lead_email, self.email, campaign.email_signup)
        rescue
          # Mandrill sometimes throws an exception here.  There's not much we can do about it.
        end
      end
    end

    if !self.mobile.nil?
      if !campaign.mobile_commons.nil?
        logger.info "Sending mobile commons (#{campaign.mobile_commons}) text to (#{self.mobile})"
        Services::MobileCommons.subscribe(self.mobile, campaign.mobile_commons)
      end
    end
  end

  def action_count(campaign_id)
    share_count = 0
    vote_count = 0
    Post.where(campaign_id: campaign_id).each do |post|
      share_count += post.shares.where(uid: self.uid).count
      vote_count += post.voted_by?(self) ? 1 : 0
    end

    share_count + vote_count
  end

  def participated?(campaign_id)
    !self.participations.where(campaign_id: campaign_id).empty?
  end

  # Votes on a post.
  # @param [String] type A type of vote -- up or down.
  # @param [Object] post An instance of Post that can be voted against
  # @return [Bool] The color as a boolean
  def perform_vote type, post
    color = true

    if type == 'up'
      if self.voted_against?(post)
        self.vote_exclusively_against(post)
      elsif self.voted_on?(post)
        self.unvote_for(post)
        color = false
      else
        self.vote_for(post)
      end
    else
      if self.voted_for?(post)
        self.vote_exclusively_against(post)
      elsif self.voted_on?(post)
        self.unvote_for(post)
        color = false
      else
        self.vote_against(post)
      end
    end

    color
  end
end

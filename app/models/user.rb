class User < ActiveRecord::Base
  attr_accessible :email, :fbid, :uid, :is_admin

  include Services

  # checks if a user with the given email exists in the DoSomething drupal database
  def self.exists?(email)
    if email.nil? || Services::Auth.check_exists(email).first.nil?
      false
    else
      true
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
  def self.login(session, username, password, cell, fbid)
    if fbid != 0 # if logging in with Facebook
      uid = Services::Auth.check_admin(username).first['uid']
      if uid
        roles = { 1 => 'administrator', 2 => 'authenticated user' }
      else
        uid = Services::Auth.check_exists(username).first['uid']
        if uid
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
        cell = response["profile"]["field_user_mobile"]["und"][0]["value"]
      else
        return false
      end
    end

    user = User.find_by_uid(uid)
    if !user # creates a new user if he/she isn't already in the database
      user = User.new(:uid => uid, :fbid => fbid, :email => username, :is_admin => roles.values.include?('administrator'))
      # handle mailchimp and mobilecommons if email/cell are provided
      email = username
      if !email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
        email = nil
      end
      handle_mc(email, cell)
    elsif fbid != 0 # adds a fbid if they are logging in with facebook for the first time
      user.fbid = fbid
    end
    user.save

    # set up session for current user
    session[:drupal_user_id] = response['user']['uid']
    session[:drupal_user_role] = response['user']['roles']
    return true
  end
end

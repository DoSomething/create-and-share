class User < ActiveRecord::Base
  attr_accessible :email, :fbid, :uid, :is_admin

  include Services

  def self.exists?(email)
    if email.nil?
      false
    elsif Services::Auth.check_exists(email).first
      true
    else
      false
    end
  end

  def self.register(password, email, fbid, first, last, cell, birthday, is_admin = false)
    bday = Date.strptime(birthday, '%m/%d/%Y')
    response = Services::Auth.register(password, email, first, last, cell, bday.month, bday.day, bday.year)
    if response.code == 200 && response.kind_of?(Hash)
      return true
    else
      return false
    end
  end

  def self.login(session, username, password, cell, fbid)
    if fbid != 0
      uid = Services::Auth.check_admin(username).first['uid']
      if uid
        roles = { 1 => 'administrator', 2 => 'authenticated user' }
      else
        uid = Services::Auth.check_exists(username).first['uid']
        roles = { 1 => 'authenticated user'}
      end
    else
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
    if !user
      user = User.new(:uid => uid, :fbid => fbid, :email => username, :is_admin => roles.values.include?('administrator'))
      email = username
      if !email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
        email = nil
      end
      handle_mc(email, cell)
    elsif fbid != 0
      user.fbid = fbid
    end
    user.save
    session[:drupal_user_id] = response['user']['uid']
    session[:drupal_user_role] = response['user']['roles']
    return true
  end
end

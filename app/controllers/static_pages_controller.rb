class StaticPagesController < ApplicationController
  before_filter :is_not_authenticated, :verify_api_key, :except => [:faq, :auth_bar]

  # GET /start
  def guide
  end

  # GET /
  # This is for when the campaign closes -- static HTML for the finished gallery.
  def gallery
  end

  # GET /faq
  def faq
  end

  def auth_bar
    expires_now
    render partial: 'partials/auth_bar', layout: false
  end
end

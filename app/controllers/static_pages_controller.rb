class StaticPagesController < ApplicationController
  before_filter :is_not_authenticated, :verify_api_key, :except => [:faq]

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
end

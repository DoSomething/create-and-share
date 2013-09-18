class StaticPagesController < ApplicationController
  before_filter :is_not_authenticated, :verify_api_key, :except => [:faq]

  # GET /start
  def guide
    expires_in 1.day, public: true, 'max-style' => 0
  end

  # GET /
  # This is for when the campaign closes -- static HTML for the finished gallery.
  def gallery
    expires_in 1.day, public: true, 'max-style' => 0
  end

  # GET /faq
  def faq
    expires_in 1.day, public: true, 'max-style' => 0
  end
end

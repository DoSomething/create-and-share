class DashboardController < ApplicationController
  layout 'dashboard'

  # Before everything runs, run an authentication check and an API key check.
  before_filter :admin

  def index
    split = params[:split] ? params[:split] : "all"
    end_date = params[:date] ? Date.parse(params[:date]) : Date.today
    num_splits = params[:num] ? Integer(params[:num]) : 1
    title = params[:title] ? params[:title] : "home"

    data = get_data(title, split, end_date, num_splits)

    if title == "home"
      #post stats
      @cats = data[:nCats]["all"]
      @dogs = data[:nDogs]["all"]
      @others = data[:nOthers]["all"]
      @pets = data[:nPosts]["all"]

      #user stats
      @users = data[:nUsers]["all"]

      #share stats
      @shares = data[:nShares]["all"]
      @catShares = data[:nCatShares]["all"]
      @dogShares = data[:nDogShares]["all"]
      @otherShares = data[:nOtherShares]["all"]
    end

    respond_to do |format|
      format.html
      format.json { render :layout => false, :json => data }
    end
  end

  def get_data(title, split, end_date, num_splits)
    start_date = Date.today

    # a key with a name like n___ is for the given time period
    # a key with a name like total___ is for everything until the end of the given time period
    data = {
      :title => title,
      :nUsers => {},
      :nPosts => {},
      :nCats => {},
      :nDogs => {},
      :nOthers => {},
      :nShares => {},
      :nCatShares => {},
      :nDogShares => {},
      :nOtherShares => {},
      :totalPosts => {},
      :totalUsers => {},
      :totalShares => {},
      :nAdopted => {},
      :totalAdopted => {}
    }

    (0...num_splits).each do
      label = ""
      case split
      when "all"
        start_date = 20.years.ago
        label = "all"
      when "Days"
        start_date = end_date.prev_day
        label = end_date.strftime("%m/%d")
      when "Weeks"
        start_date = end_date.prev_day(7)
        label = start_date.next.strftime("%m/%d") + " - " + end_date.strftime("%m/%d")
      when "Months"
        start_date = end_date.prev_month
        label = start_date.next.strftime("%m/%d") + " - " + end_date.strftime("%m/%d")
      else
        puts "wtf"
      end

      #post data
      data[:nCats][label] = Post.where(:animal_type => 'cat', :created_at => start_date.end_of_day..end_date.end_of_day).count
      data[:nDogs][label] = Post.where(:animal_type => 'dog', :created_at => start_date.end_of_day..end_date.end_of_day).count
      data[:nOthers][label] = Post.where(:animal_type => 'other', :created_at => start_date.end_of_day..end_date.end_of_day).count
      data[:nPosts][label] = data[:nCats][label] + data[:nDogs][label] + data[:nOthers][label]
      data[:nAdopted][label] = Post.where(:adopted => true, :created_at => start_date.end_of_day..end_date.end_of_day).count
      data[:totalAdopted][label] = Post.where(:adopted => true, :created_at => 20.years.ago..end_date.end_of_day).count
      
      #user data
      data[:nUsers][label] = User.where(:created_at => start_date.end_of_day..end_date.end_of_day).count
      
      #share data
      catShares = 0
      dogShares = 0
      otherShares = 0
      posts = Post.where(:created_at => start_date.end_of_day..end_date.end_of_day)
      posts.each do |post|
        if !post.share_count.nil?
          if post.animal_type == "cat"
            catShares += post.share_count
          end
          if post.animal_type == "dog"
            dogShares += post.share_count
          end
          if post.animal_type == "other"
            otherShares += post.share_count
          end
        end
      end
      data[:nShares][label] = catShares + dogShares + otherShares
      data[:nCatShares][label] = catShares
      data[:nDogShares][label] = dogShares
      data[:nOtherShares][label] = otherShares

      #totals
      data[:totalUsers][label] = User.where(:created_at => 20.years.ago..end_date.end_of_day).count
      totalPosts = Post.where(:created_at => 20.years.ago..end_date.end_of_day)
      data[:totalPosts][label] = totalPosts.count
      data[:totalShares][label] = 0
      totalPosts.each do |post|
        if !post.share_count.nil?
          data[:totalShares][label] += post.share_count
        end
      end

      end_date = start_date
    end

    data.each do |key, value|
      if value.is_a?(Hash)
        data[key] = Hash[value.to_a.reverse]
      end
    end

    return data
  end

end
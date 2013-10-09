def get_posts(offset, count, filter = 'index')
  last_post = Post.where(campaign_id: @campaign.id, flagged: false)
  unless last_post.nil? || last_post.empty?
    last_post = last_post.last.created_at.to_i.to_s
    posts = Rails.cache.fetch filter + '-first-posts' do
      Post.where(flagged: false).last(200).reverse.map(&:id)
    end

    cached = Rails.cache.fetch filter + '-offset-' + offset.to_s + '-' + count.to_s + '/' + last_post do
      posts = posts.slice(offset, count)
      unless posts.nil?
        posts.map! do |item|
          result = Rails.cache.fetch 'post-' + item.to_s do
            Post.find(item)
          end

          result
        end
      else
        posts = []
      end

      posts
    end
  else
    cached = []
  end

  cached
end

def get_states
  { :AL => 'Alabama', :AK => 'Alaska', :AS => 'American Samoa', :AZ => 'Arizona', :AR => 'Arkansas', :CA => 'California', :CO => 'Colorado', :CT => 'Connecticut', :DE => 'Delaware', :DC => 'District of Columbia', :FL => 'Florida', :GA => 'Georgia', :GU => 'Guam', :HI => 'Hawaii', :ID => 'Idaho', :IL => 'Illinois', :IN => 'Indiana', :IA => 'Iowa', :KS => 'Kansas', :KY => 'Kentucky', :LA => 'Louisiana', :ME => 'Maine', :MH => 'Marshall Islands', :MD => 'Maryland', :MA => 'Massachusetts', :MI => 'Michigan', :MN => 'Minnesota', :MS => 'Mississippi', :MO => 'Missouri', :MT => 'Montana', :NE => 'Nebraska', :NV => 'Nevada', :NH => 'New Hampshire', :NJ => 'New Jersey', :NM => 'New Mexico', :NY => 'New York', :NC => 'North Carolina', :ND => 'North Dakota', :MP => 'Northern Marianas Islands', :OH => 'Ohio', :OK => 'Oklahoma', :OR => 'Oregon', :PW => 'Palau', :PA => 'Pennsylvania', :PR => 'Puerto Rico', :RI => 'Rhode Island', :SC => 'South Carolina', :SD => 'South Dakota', :TN => 'Tennessee', :TX => 'Texas', :UT => 'Utah', :VT => 'Vermont', :VI => 'Virgin Islands', :VA => 'Virginia', :WA => 'Washington', :WV => 'West Virginia', :WI => 'Wisconsin', :WY => 'Wyoming' }
end

def fill_post_form
  post = FactoryGirl.build(:post)
  attach_file 'post_image', Rails.root.to_s + '/spec/mocks/ruby.png'
  fill_in 'post_name', with: post.name
  fill_in 'post_city', with: post.city
  if !post.state.nil?
    select get_states[post.state.to_sym], from: 'post_state'
  else
    select 'New York', from: 'post_state'
  end
  fill_in 'post_school_id', with: post.school.title + ' (' + post.school.id.to_s + ')'
  post
end

def open_crop
  attach_file 'post_image', Rails.root.to_s + '/spec/mocks/ruby.png'
end

def crop_should_disappear
  find(:id, 'post_image').value.should eq ""
  page.should_not have_selector('#crop-overlay')
  page.should_not have_selector('#crop-container')
  page.should_not have_selector('#preview-img-container')
end

def preview_should_appear
  find(:id, 'post_image').value.should eq Rails.root.to_s + '/spec/mocks/ruby.png'
  page.should_not have_selector('#crop-overlay')
  page.should_not have_selector('#crop-container')
  page.should have_selector('#preview-img-container')
end

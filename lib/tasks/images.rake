namespace :images do
  namespace :fix do
    task :one => :environment do
      abort 'No Post ID specified.' if ARGV[1].nil?
      post_id = ARGV[1].to_i

      # Find the post and the image associated with it.
      @post = Post.find(post_id)
      if @post.nil?
        abort "No post with ID #{ARGV[1]} exists."
      end

      image = @post.image.url(:gallery)
      image = '/public' + image.gsub(/\?.*/, '')

      # Rewrite the image.
      if File.exists? Rails.root.to_s + image
        PostsHelper.image_writer(image, @post.meme_text, @post.meme_position)
      end

      abort 'Done.'
    end

    # GET /fix
    # Fixes all images should they lose their text.
    task :all => :environment do
      # Get all posts.
      @posts = Post.all
      if @posts.nil?
        abort 'There are no posts yet!'
      end

      @posts.each do |post|
        # Get the actual image path.
        image = post.image.url(:gallery)
        image = '/public' + image.gsub(/\?.*/, '')

        # Assuming the file exists, write the text.
        if File.exists? Rails.root.to_s + image
          PostsHelper.image_writer(image, post.meme_text, meme_position)
        end
      end

      abort 'Done.'
    end
  end
end
class SharesController < ApplicationController
  # POST /shares
  def create
    if request.format.symbol != :json || authenticated?
      # Fail if you're not authenticated.
      render :status => :forbidden unless authenticated?
      params[:share][:uid] = session[:drupal_user_id]
    end

    # Note: we can't put this in a model.  Models can't access the session variable.
    @share = Share.new(params[:share])
    @post = Post.find(params[:share][:post_id])
    if @post.share_count.nil? || @post.share_count == 0
      @post.share_count = params[:new_count]
    else
      @post.share_count = (@post.share_count + 1)
    end
    @post.save

    respond_to do |format|
      if @share.save
        format.html { render json: { 'success' => true } }
        format.json { render json: { 'success' => true } }
      else
        format.html { render json: { 'success' => true } }
        format.json { render json: { 'success' => false } }
      end
    end
  end
end
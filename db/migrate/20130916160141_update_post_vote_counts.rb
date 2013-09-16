class UpdatePostVoteCounts < ActiveRecord::Migration
  def up
    Post.all.each do |post|
      post.update_attribute(:thumbs_up_count, post.votes.where(vote: true).count)
      post.update_attribute(:thumbs_down_count, post.votes.where(vote: false).count)
    end

    say "Updated post counts"
  end
end

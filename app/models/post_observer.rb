class PostObserver < ActiveRecord::Observer
  def after_save(record)
  	# Build all associated tags
    Tag.create_tags(record)
  end
end

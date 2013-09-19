Rails.cache.class_eval do
  # Stores a cached key, for deletion later.
  def remember key
    keys = Rails.cache.read 'all-caches'
    keys ||= []
    unless keys.include? key
      keys << key
      Rails.cache.write 'all-caches', keys
    end
  end

  # destroys all stored keys.
  def destroy_all(request)
    all_keys = Rails.cache.read 'all-caches'
    all_keys ||= []

    all_keys.each do |key|
      Rails.cache.delete key
    end
    Rails.cache.delete 'all-caches'
    Rails.cache.delete 'views/' + request[:url]
  end
end

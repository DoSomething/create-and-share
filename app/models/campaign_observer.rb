require 'rails/generators'

class CampaignObserver < ActiveRecord::Observer
  def after_create(record)
    if !Rails.env.test?
      Rails::Generators.invoke 'campaign', [record.path]
    end
  end

  def after_destroy(record)
    if !Rails.env.test?
      Rails::Generators.invoke 'campaign', [record.path], behavior: :revoke
    end
  end
end

require 'rails/generators'
class CampaignObserver < ActiveRecord::Observer
  def after_create(record)
    if !Rails.env.test?
      Rails::Generators.invoke('campaign', [record.path])
    end
  end
end

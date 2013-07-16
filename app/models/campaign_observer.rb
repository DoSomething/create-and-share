require 'rails/generators'
class CampaignObserver < ActiveRecord::Observer
  def after_create(record)
    Rails::Generators.invoke('campaign', [record.path])
  end
end

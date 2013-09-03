class CampaignGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def files
    copy_file 'config.yml', 'config/campaigns/' + file_name + '.yml'
    empty_directory 'app/assets/javascripts/campaigns/' + file_name
    directory 'js', 'app/assets/javascripts/campaigns/' + file_name
    empty_directory 'app/assets/stylesheets/campaigns/' + file_name
    directory 'css', 'app/assets/stylesheets/campaigns/' + file_name
    empty_directory 'app/views/campaigns/' + file_name
    directory 'views', 'app/views/campaigns/' + file_name
  end
end

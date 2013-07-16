class CampaignGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_directories
    copy_file 'config.yml', 'config/campaigns/' + file_name + '.yml'
    directory 'assets_js', 'app/assets/javascripts/campaigns/' + file_name
    directory 'assets_css', 'app/assets/stylesheets/campaigns/' + file_name
  end
end

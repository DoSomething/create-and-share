class Filters
  @@filters = {}
  def initialize
  	files = Dir["#{Rails.root}/config/filters/*.yml"]
  	files.each do |file|
  	  k = Pathname.new(file).basename.to_s.gsub('.yml', '')
  	  @@filters[k] ||= []
  	  @@filters[k] = YAML::load(File.open(file))
  	end
  end

  def blah
    @@filters
  end
end

filters = Filters.new
business = filters.blah
CreateAndShare::Application.config.filters = business

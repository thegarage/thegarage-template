# monkeypatch to expose list of all available static pages
module HighVoltage
  def self.pages
    content_path = Rails.root.join('app', 'views', HighVoltage.content_path).to_s
    Dir.glob(File.join(content_path, '**/*.html.*')).map do |file|
      File.basename(file).gsub(/\..*/, '')
    end
  end
end

HighVoltage.configure do |config|
  config.home_page = 'home'
  config.route_drawer = HighVoltage::RouteDrawers::Root
end

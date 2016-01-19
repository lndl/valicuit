module Valicuit
  class Engine < Rails::Engine
    initializer 'valicuit' do
      files = Dir[Pathname.new(File.dirname(__FILE__)).join('../..', 'locales', '*.yml')]
      config.i18n.load_path += files
    end
  end
end

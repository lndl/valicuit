require 'active_model'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'valicuit'

I18n.load_path += Dir[File.expand_path(File.join(File.dirname(__FILE__), '../locales', '*.yml')).to_s]
I18n.default_locale = :test

class TestModel
  include ActiveModel::Validations

  attr_accessor :cuit

  def initialize(attributes = {})
    self.cuit = attributes[:cuit]
  end
end

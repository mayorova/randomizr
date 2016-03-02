ENV['RACK_ENV'] = 'test'
require_relative '../environment'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.color = true
end

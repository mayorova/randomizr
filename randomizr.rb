require 'sinatra/base'
require 'sinatra/namespace'
require 'json'

class Randomizr < Sinatra::Base
  register Sinatra::Namespace

  namespace '/api' do
    get '/number' do
      # generate random number from 1 to 100
      prng = Random.new
      random_num = prng.rand(100) + 1
      { number: random_num }.to_json
    end

    get '/date' do
      { date: '2016-02-27' }.to_json
    end

    get '/uuid' do
      { uuid: SecureRandom.uuid }.to_json
    end
  end
  
end





require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/param'
require 'json'
require 'bundler'

class RandomizrApi < Sinatra::Base

  register Sinatra::Namespace
  helpers Sinatra::Param

  configure do
    enable :logging
  end

  before do
    content_type :json
  end

  namespace '/api' do

    get '/number' do
      param :min, Integer,  default: 1
      param :max, Integer,  default: 100
      param :scale, Integer,  deault: 0 

      max = params[:max]
      min = params[:min]
      scale = params[:scale]

      # check max and min
      if max and min and max < min
        error = { message: "Invalid parameters, max, min", errors: { "max" => "Parameter 'min' should be less than 'max'"} }.to_json
        halt 400, error
      end

      random_num = Faker::Number.between(min, max)

      if scale and scale > 0
        dec = Faker::Number.decimal_part(scale)
        random_num = "#{random_num}.#{dec}".to_f - 1    # -1 is to ensure the resulting number <= max
      end

      { number: random_num }.to_json
    end

    get '/date' do
      param :from,  Date
      param :to,  Date

      logger.info(params[:from])
      logger.info(params[:to])

      from = params[:from]
      to = params[:to]

      if from and to and from > to
        error = { message: "Invalid parameters, from, to", errors: { "from" => "Parameter 'from' should be less than 'to'"} }.to_json
        halt 400, error
      end

      # set defaults
      from ||= Date.new(1970,1,1) # from January 1, 1970 by default
      to ||= Date.today
      # fix the defaults if necessary (if only 'from' is set, and it is after 'today')
      to = from + 365 if from > to

      logger.info(from)
      logger.info(to)

      random_date = Faker::Date.between(from, to)

      { date: random_date }.to_json
    end

    get '/uuid' do
      { uuid: SecureRandom.uuid }.to_json
    end

  end

  not_found do
    error 404, { message: "endpoint not found" }.to_json
  end
  
end





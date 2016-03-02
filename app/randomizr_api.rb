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

    # -----------------------
    # GET /number
    # -----------------------
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

    # -----------------------
    # GET /date
    # -----------------------
    get '/date' do
      param :from,  Date
      param :to,  Date

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

    # -----------------------
    # GET /time
    # -----------------------
    get '/time' do
      param :period,  String  # Accepted values: day, night, morning, afternoon, evening, midnight

      period = params[:period]

      # validate the period
      if period and !Faker::Time::TIME_RANGES.keys.include?(period.to_sym)
        error = { message: "Invalid parameters, period", errors: { "period" => "Parameter 'period' is not one of "} }.to_json
        halt 400, error
      end

      logger.info(period)
      # set defaults
      period = period.nil? ? :all : period.to_sym
      logger.info(period)

      random_time = Faker::Time.between(Date.today, Date.today-1, period) # from yesterday to today
      random_time = random_time.strftime("%H:%M:%S")

      { time: random_time }.to_json
    end

    # -----------------------
    # GET /uuid
    # -----------------------
    get '/uuid' do
      { uuid: SecureRandom.uuid }.to_json
    end

  end

  # A 404 error is sent when trying to access any endpoint that is not implemented yet
  not_found do
    error 404, { message: "endpoint not found" }.to_json
  end
  
end





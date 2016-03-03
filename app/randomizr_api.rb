require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/param'
require 'sinatra/cross_origin'
require 'marky_markov'
require 'json'

class RandomizrApi < Sinatra::Base

  register Sinatra::Namespace
  register Sinatra::CrossOrigin
  helpers Sinatra::Param

  configure do
    enable :logging
    enable :cross_origin
  end

  # configure :development do
  #   set :raise_sinatra_param_exceptions, true
  #   set :show_exceptions, false 
  #   set :raise_errors, true
  # end

  set :root, File.expand_path('.')

  # Dictionary for text generation
  set :dict_name, ENV['MARKOV_DICT']

  # CORS settings
  set :allow_origin, :any
  set :allow_methods, [:get, :post, :options]
  set :allow_credentials, true
  set :max_age, "1728000"
  set :expose_headers, ['Content-Type']

  def initialize
    super

    # Initialize the dictionary for text generation
    @dict = MarkyMarkov::Dictionary.new("#{settings.root}/dict/#{settings.dict_name}")
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
        error = { message: "Invalid parameters, max, min", errors: { "max" => "Parameter 'min' 
          should be less than 'max'"} }.to_json
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
        error = { message: "Invalid parameters, period", errors: { "period" => "Parameter 'period' is not one of the allowed"} }.to_json
        halt 400, error
      end

      # set defaults
      period = period.nil? ? :all : period.to_sym

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

    # -----------------------
    # GET /name
    # -----------------------
    get '/name' do
      random_name = Faker::Name.name
      { name: random_name }.to_json
    end

    # -----------------------
    # GET /username
    # -----------------------
    get '/username' do
      param :name,  String

      random_name = Faker::Internet.user_name(params[:name])

      { username: random_name }.to_json
    end

    # -----------------------
    # GET /email
    # -----------------------
    get '/email' do
      param :name,  String
      param :safe,  Boolean, default: false

      name = params[:name]
      random_email = params[:safe] ? Faker::Internet.safe_email(name) : Faker::Internet.email(name)

      { email: random_email }.to_json
    end

    # -----------------------
    # GET /password
    # -----------------------
    get '/password' do
      param :min_length,  Integer,  default: 8
      param :max_length,  Integer,  default: 16
      param :special_chars,  Boolean, default: false

      random_password = Faker::Internet.password(params[:min_length], params[:max_length], true, params[:special_chars])

      { password: random_password }.to_json
    end

    # -----------------------
    # GET /phone
    # -----------------------
    get '/phone' do
      param :mobile,  Boolean, default: false

      random_phone = params[:mobile] ? Faker::PhoneNumber.cell_phone : Faker::PhoneNumber.phone_number

      { phone: random_phone }.to_json
    end

    # -----------------------
    # GET /locale
    # -----------------------
    get '/locale' do
      { locale: Faker::Config.locale }.to_json
    end


    # -----------------------
    # POST /locale
    # -----------------------
    post '/locale' do
      param :code,  String, required: true

      code = params[:code].downcase
      if I18n.available_locales.map(&:to_s).map(&:downcase).include? code
        Faker::Config.locale = params[:code]
      else
        error = { message: "Invalid parameters, code", errors: { "code" => "Locale code is not one of the allowed"} }.to_json
        halt 400, error
      end

      { message: "Locale '#{params[:code]}' saved successfully" }.to_json
    end

    # -----------------------
    # POST /locale
    # -----------------------
    post '/locale' do
      param :code,  String, required: true

      code = params[:code].downcase
      if I18n.available_locales.map(&:to_s).map(&:downcase).include? code
        Faker::Config.locale = params[:code]
      else
        error = { message: "Invalid parameters, code", errors: { "code" => "Locale code is not one of the allowed"} }.to_json
        halt 400, error
      end

      { message: "Locale '#{params[:code]}' saved successfully" }.to_json
    end

  end

  # -----------------------
  # GET /text/:source/words
  # -----------------------
  get '/textgen/:source/words' do |source|
    param :count, Integer
    count = params[:count] || 5

    if source.downcase == "lorem"
      random_words = Faker::Lorem.words(count)
    else
      halt 404
    end

    { words: random_words }.to_json
  end

  # -----------------------
  # GET /text/:source/paragraph
  # -----------------------
  get '/textgen/:source/paragraph' do |source|
    param :count, Integer
    count = params[:count] || 5

    if source.downcase == "lorem"
      random_text = Faker::Lorem.paragraph(count)
    elsif source.downcase == "3scale"
      random_text = @dict.generate_n_sentences(count)
    else
      halt 404
    end
    
    { text: random_text }.to_json
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    200
  end

  # A 404 error is sent when trying to access any endpoint that is not implemented yet
  not_found do
    error 404, { message: "Endpoint not found" }.to_json
  end

  # Send a 500 error for any other error
  error do
    error 500, { message: "Server error" }.to_json
  end
  
end





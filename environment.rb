require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require File.dirname(__FILE__) + '/app/randomizr_api.rb'

# # use this if there are more files to require:
# Dir[File.dirname(__FILE__) + '/app/*.rb'].each {|file| require file }
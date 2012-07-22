require 'rubygems'
require 'bundler'

Bundler.require

require './litter'
run Sinatra::Application

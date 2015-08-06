require 'rubygems'
require 'rspec'
require 'pry'
require "codeclimate-test-reporter"

ENV['RACK_ENV'] = 'test'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$LOAD_PATH << File.join(File.dirname(__FILE__),'..')
CodeClimate::TestReporter.start if !!ENV['CODECLIMATE_REPO_TOKEN']
require 'config/environment'
include RubyNos

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation # :documentation, :progress, :html, :textmate
end




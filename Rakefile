require 'rubygems'
require 'bundler'

begin
Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
$stderr.puts e.message
$stderr.puts "Run `bundle install` to install missing gems"
exit e.status_code
end
require 'rake'

require 'rspec/core/rake_task'
task :default => :spec
task :test => :spec
desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |spec|
spec.rspec_opts = %w{}
end
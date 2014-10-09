root_path = File.join(File.dirname(__FILE__),'..')
lib_path = File.join(root_path,'lib')
app_name = 'ruby_nos'
# Add all files to Load path
$LOAD_PATH << root_path
$LOAD_PATH << lib_path
$LOAD_PATH << File.join(lib_path, app_name)
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require app_name
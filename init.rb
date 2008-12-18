require 'rubygems'
gem 'mechanize', ">= 0.7.6"
gem "hpricot", ">= 0.6"
require 'hpricot'
require 'mechanize'
::Hpricot.buffer_size = 524288

%w[web_sickle assertions hash_proxy helpers/asp_net helpers/table_reader].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', file + '.rb')
end
require 'rubygems'
require 'mechanize'
%w[web_sickle assertions hash_proxy helpers/asp_net helpers/table_reader mechanize_overrides/mechanize_form].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', file + '.rb')
end
WebSickle::Base.send :include, WebSickle::Assertions
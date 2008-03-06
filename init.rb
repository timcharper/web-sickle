%w[web_sickle assertions helpers/asp_net helpers/table_reader].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', file + '.rb')
end
WebSickle::Base.send :include, WebSickle::Assertions
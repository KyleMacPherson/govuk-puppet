require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  c.manifest    = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..')) + "/manifests/site.pp"
end

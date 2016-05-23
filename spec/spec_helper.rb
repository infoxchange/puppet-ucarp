require 'puppetlabs_spec_helper/module_spec_helper'

def fixture_path
  File.expand_path(File.join(__FILE__, '..', 'fixtures'))
end

RSpec.configure do |conf|
  conf.formatter = 'documentation'
  conf.module_path = File.join(fixture_path, 'modules')
  conf.manifest_dir = File.join(fixture_path, 'manifests')
end

if ENV['PUPPET_DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end


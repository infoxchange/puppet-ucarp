require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  # Want 100% test coverage.
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(100)
  end
end

if ENV['PUPPET_DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end


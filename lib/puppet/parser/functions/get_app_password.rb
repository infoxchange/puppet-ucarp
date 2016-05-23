require 'digest/md5'

module Puppet::Parser::Functions
  newfunction(:get_app_password, :type => :rvalue) do |args|
  	return Digest::MD5.hexdigest(args[0]).to_i(16).to_s[0..18]
  end
end

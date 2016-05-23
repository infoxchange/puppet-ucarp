#
# Determines if the current node is the master
#
# Params:
# arg[0] = application name
# arg[1] = list of hosts in the cluster (array).  Must be fqdn.
# arg[2] = hostname of the master, if a preferred master is nominated.  Must be fdqn.
#
module Puppet::Parser::Functions
  newfunction(:is_node_master, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
  	if function_get_node_priority([args[0], args[1], args[2]]) == 0
      return true
    else
      return false
    end
  end
end

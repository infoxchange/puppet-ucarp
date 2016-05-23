require 'digest/md5'

#
# Determines node priority, given the list of hosts that comprise this 'cluster'
#
# Params:
# arg[0] = application name
# arg[1] = list of hosts in the cluster (array).  Must be fqdn.
# arg[2] = hostname of the master, if a preferred master is nominated.  Must be fdqn.
#          if this is set, then this node gets priority, otherwise the first
#          host in the node list is designated the master.
#
module Puppet::Parser::Functions
  newfunction(:get_node_priority, :type => :rvalue) do |args|
    app = args[0]
    nodelist = args[1]
    preferred_master = args[2]

  	myapp = Digest::MD5.hexdigest(app + lookupvar('::fqdn')).to_i(16).to_s
  	priorities = []
  	nodelist.each {|host|
      if preferred_master == false
        priorityforhost = Digest::MD5.hexdigest(app + host).to_i(16).to_s
      else
        if host == preferred_master
          priorityforhost = "0"
        else
          priorityforhost = Digest::MD5.hexdigest(app + host).to_i(16).to_s
        end
      end
  		priorities << priorityforhost
  	}
  	priorities.sort!

    if lookupvar('::fqdn') == preferred_master
      prioindex = 0
    else
  	  prioindex = priorities.index(myapp)
    end
    unless prioindex != nil
      raise(Puppet::ParseError, 'FQDN of ' + lookupvar('::fqdn') + ' not in supplied nodelist')
    end

  	return prioindex
  end
end

# https://docs.puppet.com/guides/custom_functions.html

require 'ipaddr'

module Puppet::Parser::Functions

  newfunction(:ucarp_vhid_conflict_check, :type => :rvalue) do |args|
    my_ucarp_dev = args[0]
    my_vhid = args[1]
    my_networking = args[2]	# hash from facter, passed in as an argument
    my_hostname = my_networking['hostname']
    my_fqdn = my_networking['fqdn']
  
    ucarp_resources = function_query_resources(['Ucarp::Vip[*]', 'Ucarp::Vip[*]', true])

    if my_networking['interfaces'].has_key?(my_ucarp_dev)
      my_network_str = my_networking['interfaces'][my_ucarp_dev]['network'] + '/' + my_networking['interfaces'][my_ucarp_dev]['netmask']
    else
      raise Puppet::ParseError, 'Could not get network address for '+my_ucarp_dev.to_s+' from facter'
    end
  
    # The network address of the ucarp vip
    my_network = IPAddr.new my_network_str

    conflicting_hostnames = []
    ucarp_resources.keys.each do |hostname|
      # each host can have multiple vips, so we get an array of resources per host
      ucarp_resources[hostname].each do |ucarp_vip|
        if ucarp_vip['parameters'].has_key?('vhid')
          ucarp_vhid = ucarp_vip['parameters']['vhid']
        elsif ucarp_vip['parameters'].has_key?('node_id')  # for backwards compatability
          ucarp_vhid = ucarp_vip['parameters']['node_id']
        else
          # default is 001 if not specified (see module ucarp)
          ucarp_vhid = '001'
        end
        ucarp_cluster = ucarp_vip['parameters']['cluster_nodes']   # an array of hostnames
        if not ucarp_cluster.nil? and ( ucarp_cluster.include?(my_hostname) or ucarp_cluster.include?(my_fqdn) )
          # hostname is in the same cluster my_hostname
          if ucarp_vhid == my_vhid
            # And this resource has the same vhid = no conflict
            next
          end
        end
        ucarp_ip = IPAddr.new ucarp_vip['parameters']['vip_ip_address']
        if my_network.include?(ucarp_ip) and (ucarp_vhid.to_i % 256) == (my_vhid.to_i % 256) and not conflicting_hostnames.include?(hostname)
          conflicting_hostnames.push(hostname)
        end
      end
    end    # ucarp_resources.keys.each hostname
    return conflicting_hostnames
  end    # newfunction
end    # module

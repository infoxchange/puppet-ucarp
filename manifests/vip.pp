#
# Class: ucarp::vip
# ===========================
#
# This class manages configuration of a ucarp 'vip' instance, and installs systemd configuration
# for that service.
#
# Supported OS:
# - CentOS 7.x
#
# Parameters
# ----------
#
# * `cluster_name`
#   VIP or cluster name for use in calculating MD5 hashes, especially when multiple
#   instances are running on a single host.  Also used to generate passwords if one not specified.
#   Defaults to `$name` for this resource
#
# * `cluster_nodes`
#   List of hostnames (FQDN) that will utilise this ucarp configuraiton.
#   Assumption is that the first node in the list is the master, unless otherwise stated.
#
# * `vip_ip_address`
#   Virtual IP address. Required.
#
# * `node_id`
#   Number betwen 001 and 255, used to generate VIP configuration in `/etc/ucarp/vip-<node_id>.conf`.
#   If an existing number is provided, this configuration will be overwritten.  Defaults to `001`.
#
# * `host_ip_address`
#   The real IP address of this host.  Defaults to facter value for `$::ipaddress`.
#
# * `app_password`
#   VIP password.  Generated if not supplied.
#
# * `master_host`
#   Name of the master host.  Should be fqdn. If not specified, the master host will be deemed
#   to be the first host listed in `cluster_nodes`. Optional.
#
# * `network_interface`
#   Network interface to use.  Default is `eth0`.
#
# Examples
# --------
#
# ON each node to be clustered, include an interface definition.
#
# # @example
# ucarp::vip { 'nginx_cluster':
#  cluster_name   => 'nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.1',
#  node_id        => '001',
# }
#
# @example
# Simple definition, for 2 nodes with a specific master
# ucarp::vip { 'nginx_cluster':
#  cluster_name   => 'nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.1',
#  node_id        => '001',
#  master_host    => 'nginx-02.example.com',
# }
#
#
# @example
# Simple definition, for 2 nodes with overrides
# class { 'ucarp':
#   manage_package => false,
# }
#
# ucarp::vip { 'nginx_cluster':
#  cluster_name   => 'nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.1',
#  node_id        => '001',
# }
#
#
# @example
# Definition, for 2 nodes, with multiple ucarp instances
# ucarp::vip { 'nginx_cluster-01':
#  cluster_name   => 'dev_nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.1',
#  node_id        => '001',
# }
#
# ucarp::vip { 'nginx_cluster-02':
#  cluster_name   => 'uat_nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.2',
#  node_id        => '002',
# }
#
# ucarp::vip { 'nginx_cluster-03':
#  cluster_name   => 'prod_nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.3',
#  node_id        => '003',
# }
#
#
#
# Authors
# -------
#
# Josie Gioffre <jgioffre@infoxchange.org>
#
# Copyright
# ---------
#
# Copyright 2016 Infoxchange
#
define ucarp::vip (
  $cluster_name      = undef,
  $cluster_nodes     = undef,
  $vip_ip_address    = undef,
  $node_id           = undef,
  $host_ip_address   = undef,
  $app_password      = undef,
  $master_host       = undef,
  $network_interface = undef,
) {

  include ::ucarp

  $_node_id           = pick($node_id, $ucarp::node_id)
  $_host_ip_address   = pick($host_ip_address, $ucarp::host_ip_address)
  $_app_password      = pick($app_password, $ucarp::app_password)
  $_master_host       = pick($master_host, $ucarp::master_host)
  $_network_interface = pick($network_interface, $ucarp::network_interface)

  validate_array($_cluster_nodes)
  validate_ip_address($_vip_ip_address)

  if $_node_id == undef or empty($_node_id) {
    fail('Node ID is expected')
  }

  validate_ip_address($_host_ip_address)

  if $_network_interface == undef or empty($_network_interface) {
    fail('Network Interface is expected')
  }

  $real_cluster_name = pick($_cluster_name, $name)
  $real_app_password =  pick($_app_password, get_app_password($real_cluster_name))
  $is_master = pick($_master_host, is_node_master($real_cluster_name, $_cluster_nodes, $_master_host))

  # Uses vars:
  # - _node_id
  # - _vip_ip_address
  # - real_app_password
  # - _network_interface
  # - _host_ip_address
  # - is_master
  file { "/etc/ucarp/vip-${node_id}":
    ensure  => present,
    content => template('ucarp/vip-XXX.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
  }

}

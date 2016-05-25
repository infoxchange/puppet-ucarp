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
#   Name of the master host.  Should be fqdn. If not specified, the master host will be
#   randomly assigned.  Optional.
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
  $ensure            = present,
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

  $real_cluster_name      = pick($cluster_name, $name)
  $real_node_id           = pick($node_id, $ucarp::node_id)
  $real_host_ip_address   = pick($host_ip_address, $ucarp::host_ip_address)
  $real_app_password      = pick($app_password, get_app_password($real_cluster_name))
  $real_network_interface = pick($network_interface, $ucarp::network_interface)

  validate_re($ensure, '^present$|^absent$', 'Invalid value for ensure')
  if $cluster_nodes == undef or empty($cluster_nodes) {
    fail('Cluster Nodes is expected.')
  }
  validate_array($cluster_nodes)
  if !member($cluster_nodes, $::fqdn) {
    fail('Current node must be included within the nodelist.  Value must be FQDN.')
  }

  if $vip_ip_address == undef or empty($vip_ip_address) {
    fail('VIP IP Address is expected.')
  }
  validate_ip_address($vip_ip_address)

  if $real_node_id == undef or empty($real_node_id) {
    fail('Node ID is expected.')
  }
  validate_re($real_node_id, '^\d\d\d$', 'Invalid value for Node ID.  Must be a value from "000" to "255"')

  validate_ip_address($real_host_ip_address)

  $real_master_host = pick_default($master_host, $cluster_nodes[0])
  $is_master = is_node_master($real_cluster_name, $cluster_nodes, $real_master_host)

  # Uses vars:
  # - real_node_id
  # - vip_ip_address
  # - real_app_password
  # - real_network_interface
  # - real_host_ip_address
  # - is_master
  file { "/etc/ucarp/vip-${real_node_id}.conf":
    ensure  => $ensure,
    content => template('ucarp/vip-XXX.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    notify  => Service["ucarp@${real_node_id}"],
  }

  case $ensure {
    'present': {
      $service_ensure = 'running'
      $service_enable = 'true'
    }
    'absent': {
      $service_ensure = 'stopped'
      $service_enable = 'false'
    }
    default: {
      # do nothing
    }
  }

  # Template systemd service is added, and we can have multiple instances running.
  service { "ucarp@${real_node_id}":
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

}

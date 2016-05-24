# Class: ucarp
# ===========================
#
# This class manages installation of ucarp, and related configuration.
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
# * `app_password`
#   VIP password.  Generated if not supplied.
#
# * `node_id`
#   Number betwen 001 and 255, used to generate VIP configuration in `/etc/ucarp/vip-<node_id>.conf`.
#   If an existing number is provided, this configuration will be overwritten.  Defaults to `001`.
#
# * `master_host`
#   Name of the master host.  Should be fqdn. If not specified, the master host will be deemed
#   to be the first host listed in `cluster_nodes`. Optional.
#
# * `host_ip_address`
#   The real IP address of this host.  Defaults to facter value for `$::ipaddress`.
#
# * `network_interface`
#   Network interface to use.  Default is `eth0`.
#
# * `manage_package`
#   Should this module manage installation of the package.  Default `true`
#
# * `package_ensure`
#   If package is managed, ensure status.  Defaults to `present`.
#
# * `package_name`
#   Name of the package providing ucarp service. Defaults to `ucarp`.
#
#
# Examples
# --------
#
# ON each node to be clustered, include an interface definition.
#
# # @example
# ucarp::vip { 'nginx_cluster':
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.1',
# }
#
# @example
# Simple definition, for 2 nodes with a specific master
# ucarp::vip { 'nginx_cluster':
#  cluster_name   => 'my_nginx_cluster',
#  cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
#  vip_ip_address => '192.168.1.1',
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
class ucarp (
  $cluster_name      = undef,
  $cluster_nodes     = undef,
  $vip_ip_address    = undef,
  $app_password      = undef,
  $master_host       = undef,
  $node_id           = $ucarp::params::node_id,
  $host_ip_address   = $ucarp::params::host_ip_address,
  $network_interface = $ucarp::params::network_interface,
  $manage_package    = $ucarp::params::manage_package,
  $package_ensure    = $ucarp::params::package_ensure,
  $package_name      = $ucarp::params::package_name,
) inherits ucarp::params {

  anchor {'ucarp::start': } ->
  class { 'ucarp::install': } ->
  class { 'ucarp::config': } ->
  class { 'ucarp::service': } ->
  anchor {'ucarp::end': }

}


# UCARP

#### Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module configures the network interface to start up on a virtual IP, and
optionally, manages installation of ucarp.  Multiple ucarp instances on the same host are also supported.

It installs the `ucarp` package and creates a configuration file in `/etc/ucarp/vip-*.conf` for each
ucarp instance required.

Supported/tested versions:
OS: CentOS 7.x
Puppet: 4.x

### More about UCARP

UCARP allows a couple of hosts to share common virtual IP addresses in order
to provide automatic failover. It is a portable userland implementation of the
secure and patent-free Common Address Redundancy Protocol (CARP, OpenBSD’s
alternative to the patents-bloated VRRP).

For more information on UCARP: https://download.pureftpd.org/ucarp/README


## Usage

To get started, this example shows how to install the ucarp service and create
configuration for a 2-node 'cluster'.  This resource definition would be created
on each node in the cluster.

```
  ucarp::vip { 'nginx_cluster':
    cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
    vip_ip_address => '192.168.1.1',
  }
```

By default, the master will be randomly assigned.
To set a different master, override with setting `master_host`.

```
  ucarp::vip { 'nginx_cluster':
    cluster_name   => 'nginx_cluster',
    cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
    vip_ip_address => '192.168.1.1',
    node_id        => '001',
    master_host    => 'nginx-02.example.com',
  }

```


Simple definition, for 2 nodes with overrides.

```
  class { 'ucarp':
    manage_package    => false,
    cluster_name      => 'my_nginx_cluster',
    app_password      => 'somepassword',
    network_interface => 'eth1',
  }

  ucarp::vip { 'nginx_cluster':
    cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
    vip_ip_address => '192.168.1.1',
    node_id        => '001',
  }

```


Slightly more complex definition, for 2 nodes, with multiple ucarp instances with
different `vip_ip_address` and `node_id`.  If an existing `node_id` is entered,
the configuration will be overwritten.

```
  ucarp::vip { 'nginx_cluster-01':
    cluster_name   => 'dev_nginx_cluster',
    cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
    vip_ip_address => '192.168.1.1',
    node_id        => '001',
  }

  ucarp::vip { 'nginx_cluster-02':
    cluster_name   => 'uat_nginx_cluster',
    cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
    vip_ip_address => '192.168.1.2',
    node_id        => '002',
  }

  ucarp::vip { 'nginx_cluster-03':
    cluster_name   => 'prod_nginx_cluster',
    cluster_nodes  => ['nginx-01.example.com','nginx-02.example.com'],
    vip_ip_address => '192.168.1.3',
    node_id        => '003',
  }

```

## Reference

*ucarp::vip*

Definition to manage ucarp vip configuration files.

* ensure (property) - Defaults to `present`.  If `absent`, only configuration for the
  specific `node_id` will be removed.

* cluster_name (parameter) - VIP or cluster name for use in calculating MD5 hashes,
  especially when multiple instances are running on a single host.  Also used to
  generate passwords if one not specified.  Defaults to `$name` for this resource.

* cluster_nodes (parameter) - List of hostnames (FQDN) that will utilise this ucarp configuration.
 Assumption is that the first node in the list is the master, unless otherwise stated. Required.

* vip_ip_address (parameter) - Virtual IP address. Required.

* node_id (parameter) - Number betwen 001 and 255, used to generate VIP configuration in
  `/etc/ucarp/vip-<node_id>.conf`.  If an existing number is provided, this configuration
  will be overwritten.  Defaults to `001`.

* host_ip_address (parameter) - The real IP address of this host.  Defaults to facter
  value for `$::ipaddress`.

* app_password (parameter) - VIP password.  Generated if not supplied.

* master_host (parameter) - Name of the master host.  Should be fqdn. If not specified,
  the master host will be deemed to be the first host listed in `cluster_nodes`. Optional.

* network_interface (parameter) - Network interface to use.  Default is `eth0`.


## Limitations

This module is compatible with Puppet versions >= 4.x, and has only been tested with
CentOS versions >= 7.2.x

## Development

Any contributions and updates welcome.  Please create a PR with your changes,
and ensure that tests and coverage have been updated/maintained with your code.
Tests must pass before any PR will be accepted. Code coverage must be maintained
at 100%.

Alternatively, please log an issue/feature request.



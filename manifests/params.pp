class ucarp::params {

  $network_interface = 'eth0'
  $node_id           = '001'

  $manage_package    = true
  $package_ensure    = 'latest'
  $package_name      = ['ucarp']

  $host_ip_address   = "${::ipaddress}"

}

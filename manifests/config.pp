# Class to configure the system to work with ucarp.
class ucarp::config inherits ucarp {

  sysctl { 'net.ipv4.ip_nonlocal_bind':
    value => '1'
  }

}

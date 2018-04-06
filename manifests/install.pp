class ucarp::install inherits ucarp {

 if $ucarp::manage_package {
    package { $ucarp::package_name:
      ensure => $ucarp::package_ensure,
    }
  }

  file { ['/etc/ucarp/vip-001.conf.example','/etc/ucarp/vip-001.pwd.example']:
    ensure => absent,
  }

}

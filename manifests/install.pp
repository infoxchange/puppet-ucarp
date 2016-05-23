class ucarp::install inherits ucarp {

 if $ucarp::manage_package {
    package { $ucarp::package_name:
      ensure => $ucarp::package_ensure,
    }
  }

}

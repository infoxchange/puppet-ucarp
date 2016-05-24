# Class to manage the ucarp service
class ucarp::service inherits ucarp {

  service { 'ucarp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}

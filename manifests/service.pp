# Class to manage the ucarp service
class ucarp::service {

  service { 'ucarp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}

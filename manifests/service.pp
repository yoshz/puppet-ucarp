class ucarp::service {
  service { $ucarp::params::service:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$ucarp::params::package],
  }
}
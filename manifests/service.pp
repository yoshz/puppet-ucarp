class ucarp::service {
  if length($ucarp::hosts) > 0 {
    $ensure = running
    $enable = true
  } else {
    $ensure = stopped
    $enable = false
  }
  service { $ucarp::params::service:
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$ucarp::params::package],
  }
}
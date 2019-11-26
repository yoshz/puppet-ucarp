# Class ucarp::install
class ucarp::install {
  package { $ucarp::params::package:
    ensure => installed,
  }
}

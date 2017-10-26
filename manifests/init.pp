# Class uarp
class ucarp (
  Optional[String] $bind_interface = undef,
  Optional[String] $password = undef,
  Hash $hosts = {},
) inherits ucarp::params {
  contain ::ucarp::install
  contain ::ucarp::config
  contain ::ucarp::service

  create_resources('ucarp::host', $hosts)
}

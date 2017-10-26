define ucarp::host (
  String $vip_address,
  String $ensure = present,
  String $node_id = $name,
  String $source_address = $::ipaddress,
  String $master_hostname = $::hostname,
  String $bind_interface = $ucarp::bind_interface,
  String $password = $ucarp::password,
){
  include ::ucarp

  $is_master = $master_hostname == $::hostname

  file {"${ucarp::params::config_dir}/vip-${node_id}.conf":
    ensure   => $ensure,
    content  => template("ucarp/vip-000.conf.erb"),
    mode     => "0600",
    owner    => "root",
    group    => "root",
    notify   => Service[$ucarp::params::service],
    require  => File[$ucarp::params::config_dir],
  }
}
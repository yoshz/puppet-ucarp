# Resource ucarp::host
define ucarp::host (
  String $vip_address,
  String $ensure = present,
  String $node_id = $name,
  String $master_hostname = $::hostname,
  String $bind_interface = $ucarp::bind_interface,
  String $source_address = $facts['networking']['interfaces'][$bind_interface]['ip'],
  String $backup_up_script = $ucarp::params::up_script,
  String $backup_down_script = $ucarp::params::down_script,
  Optional[String] $password = undef,
  Optional[String] $master_up_script = undef,
  Optional[String] $master_down_script = undef,
){
  include ::ucarp

  $is_master = $master_hostname == $::hostname

  if $is_master and $master_up_script {
    $up_script = $master_up_script
  } else {
    $up_script = $backup_up_script
  }

  if $is_master and $master_down_script {
    $down_script = $master_down_script
  } else {
    $down_script = $backup_down_script
  }

  file {"${ucarp::params::config_dir}/vip-${node_id}.conf":
    ensure  => $ensure,
    content => template('ucarp/vip-000.conf.erb'),
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    notify  => Service[$ucarp::params::service],
    require => File[$ucarp::params::config_dir],
    before  => Service[$ucarp::params::service],
  }
}

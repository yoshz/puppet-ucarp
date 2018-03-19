class ucarp::config {
  file { $ucarp::params::config_dir:
    ensure  => directory,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
  }
  file { "${ucarp::params::config_dir}/vip-common.conf":
    ensure  => file,
    owner   => "root",
    group   => "root",
    mode    => "0600",
    content => template('ucarp/vip-common.conf.erb'),
    notify  => Service[$ucarp::params::service],
  }
  file { "${ucarp::params::script_dir}/ucarp":
    ensure  => file,
    owner   => "root",
    group   => "root",
    mode    => "0700",
    source  => "puppet:///modules/ucarp/ucarp.sh",
  }
  file { "${ucarp::params::script_dir}/vip-up":
    ensure  => file,
    owner   => "root",
    group   => "root",
    mode    => "0700",
    source  => "puppet:///modules/ucarp/vip-up.sh",
  }
  file { "${ucarp::params::script_dir}/vip-down":
    ensure  => file,
    owner   => "root",
    group   => "root",
    mode    => "0700",
    source  => "puppet:///modules/ucarp/vip-down.sh",
  }
}
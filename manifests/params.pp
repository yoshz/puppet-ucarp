class ucarp::params {
  case $::osfamily {
    'RedHat' : {
      $package    = 'ucarp'
      $service    = 'ucarp@vip-001'
      $config_dir = '/etc/ucarp'
      $script_dir = '/usr/libexec/ucarp'
    }
    default  : {
      fail('Unsupported OS')
    }
  }
}
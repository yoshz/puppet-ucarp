# Class ucarp::params
class ucarp::params {
  case $::osfamily {
    'RedHat' : {
      $package    = 'ucarp'
      $service    = 'ucarp@vip-001'
      $config_dir = '/etc/ucarp'
      $script_dir = '/usr/libexec/ucarp'
      $up_script  = "${script_dir}/vip-up"
      $down_script = "${script_dir}/vip-down"
    }
    default  : {
      fail('Unsupported OS')
    }
  }
}

#
# = Define: zabbix::server::config
#
# This define adds custom config file to Zabbix server's conf
# directory.
define zabbix::server::config (
  $settings,
  $dir_zabbix_server_confd = $::zabbix::params::dir_zabbix_server_confd,
  $notify_service          = true,
) {
  include ::zabbix::server

  $service_to_notify = $notify_service ? {
    default => undef,
    true    => Service['zabbix-server'],
  }

  file { "${dir_zabbix_server_confd}/${name}.conf":
    ensure  => file,
    content => template('zabbix/custom.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$dir_zabbix_server_confd],
    notify  => $service_to_notify,
  }

}

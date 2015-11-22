#
# = Define: zabbix::agent::config
#
# This define adds custom config file to Zabbix agent's conf
# directory.
define zabbix::agent::config (
  $settings,
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $notify_service         = true,
) {
  include ::zabbix::agent

  $service_to_notify = $notify_service ? {
    default => undef,
    true    => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agentd_confd}/${name}.conf":
    ensure  => file,
    content => template('zabbix/custom.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$dir_zabbix_agentd_confd],
    notify  => $service_to_notify,
  }

}

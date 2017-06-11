#
# = Class: zabbix::agent::net_overruns
#
# Adds items for network interface overruns items
#
class zabbix::agent::net_overruns (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/net_overruns.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/net_overruns.conf',
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }
}

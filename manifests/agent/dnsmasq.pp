#
# = Class: zabbix::agent::dnsmasq
#
# This module installs zabbix dnsmasq sensor
#
class zabbix::agent::dnsmasq (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/dnsmasq.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/dnsmasq.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => [ Package['dnsmasq'] ],
  }

}

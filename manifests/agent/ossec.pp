#
# = Class: zabbix::agent::ossec
#
# This module installs zabbix ossec sensor
#
class zabbix::agent::ossec (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/ossec.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/ossec.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => [ Package['wazuh-manager'] ],
  }

}

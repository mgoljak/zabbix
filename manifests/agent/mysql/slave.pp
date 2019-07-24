#
# = Class: zabbix::agent::mysql::slave
#
# This module installs zabbix mysql slave sensor
#
class zabbix::agent::mysql::slave (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/mysql-slave.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mysql-slave.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

}

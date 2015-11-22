#
# = Class: zabbix::agent::mysql::slave
#
# This module installs zabbix mysql slave sensor
#
class zabbix::agent::mysql::slave (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  package { 'zabbix-agent_mysql-slave':
    ensure   => present,
  }

  file { "${dir_zabbix_agentd_confd}/mysql-slave.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mysql-slave.conf.erb'),
    require => Package['zabbix-agent_mysql-slave'],
    notify  => Service['zabbix-agent'],
  }

}

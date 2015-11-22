#
# = Class: zabbix::agent::mysql
#
# This module installs zabbix mysql sensor
#
class zabbix::agent::mysql (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  package { 'zabbix-agent_mysql':
    ensure   => present,
    require  => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agentd_confd}/mysql.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mysql.conf.erb'),
    require => Package['zabbix-agent_mysql'],
    notify  => Service['zabbix-agent'],
  }

}

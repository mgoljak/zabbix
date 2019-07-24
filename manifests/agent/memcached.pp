#
# = Class: zabbix::agent::mmemcached
#
# This module installs zabbix memcached sensor
#
class zabbix::agent::memcached (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/memcached.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/memcached.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/memcached.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/memcached.pl',
    notify => Service['zabbix-agent'],
  }

}

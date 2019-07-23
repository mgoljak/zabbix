#
# = Class: zabbix::agent::beegfs
#
# This module installs Zabbix BeeGFS sensor
#
class zabbix::agent::beegfs (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/beegfs.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  =>  'puppet:///modules/zabbix/agent/beegfs/beegfs.conf',
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/zabbix-beegfs.pl"],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/zabbix-beegfs.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/beegfs/zabbix-beegfs.pl',
    require =>  [
      Package['zabbix-agent'],
      Package['perl-JSON'],
    ],
  }

  package { 'perl-JSON':
    ensure => present,
  }
}

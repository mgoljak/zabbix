#
# = Class: zabbix::agent::sge
#
# This module installs Zabbix SGE sensor
#
class zabbix::agent::sge (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/sge.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/sge.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/sge.pl"],
      File["${dir_zabbix_agent_libdir}/sge-lld.pl"],
      Package['perl-JSON'],
    ],
    notify  => Service['zabbix-agent'],
  }

  package { 'perl-JSON':
    ensure =>   present
  }

  file { "${dir_zabbix_agent_libdir}/sge.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/sge/sge.pl',
  }

  file { "${dir_zabbix_agent_libdir}/sge-lld.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source =>  'puppet:///modules/zabbix/agent/sge/sge-lld.pl',
  }

}

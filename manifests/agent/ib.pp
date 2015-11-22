#
# = Class: zabbix::agent::ib
#
# This module installs Zabbix Infiniband sensor
#
class zabbix::agent::ib (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $extended                = 1,
  $period                  = '',
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_ib':
    command          => '/usr/sbin/perfquery',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix Infiniband sensor',
  }

  file { "${dir_zabbix_agentd_confd}/ib.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/ib.conf.erb'),
    require => [
      Package['zabbix-agent'],
      Package['infiniband-diags'],
      File["${dir_zabbix_agent_libdir}/zabbix-ib.pl"],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/zabbix-ib.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/zabbix-ib.pl',
    require => ::Sudoers::Allowed_command['zabbix_sudo_ib'],
  }

}

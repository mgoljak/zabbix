#
# = Class: zabbix::agent::mdraid
#
# This module installs zabbix mdraid sensor
#
class zabbix::agent::mdraid (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_mdadm':
    command          => '/sbin/mdadm --detail /dev/md[0-9]*',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix mdadm --detail listing',
  }

  file { "${dir_zabbix_agentd_confd}/mdraid.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mdraid.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/check_mdraid"],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/check_mdraid" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/check_mdraid',
    require => ::Sudoers::Allowed_command['zabbix_sudo_mdadm'],
  }

}

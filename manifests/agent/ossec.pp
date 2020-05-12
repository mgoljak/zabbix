#
# = Class: zabbix::agent::ossec
#
# This module installs zabbix ossec/wazuh sensor
#
class zabbix::agent::ossec (
  $server_package = 'wazuh-manager',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_ossec':
    command          => '/var/ossec/bin/agent_control -l',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring OSSEC/Wazuh agents.',
  }

  file { "${dir_zabbix_agentd_confd}/ossec.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/ossec.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package[$server_package],
  }

}

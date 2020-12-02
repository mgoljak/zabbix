#
# = Class: zabbix::agent::edumeet
#
# This module installs zabbix edumeet sensor
#
class zabbix::agent::edumeet (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_edumeet':
    command          => '/usr/local/src/edumeet/server/connect.js --stats',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring eduMEET rooms and peers.',
  }

  file { "${dir_zabbix_agentd_confd}/edumeet.conf":
    ensure => file,
    owner  => root,
    group  => root,
    source => 'puppet:///modules/zabbix/agent/edumeet/edumeet.conf',
  }

}

#
# = Class: zabbix::agent::megacli
#
# This module installs zabbix megacli plugin
#
class zabbix::agent::megacli (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {
  package { 'zabbix-agent_megacli':
    ensure   => present,
    require  => Package['zabbix-agent'],
  }
}

#
# = Class: zabbix::agent::iptables
#
# This module installs zabbix iptables plugin
#
class zabbix::agent::iptables (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {
  case $::osfamily {
    default: {
      $plugin_package = 'zabbix-agent_iptables'
    }
    /(RedHat|redhat|amazon)/: {
      $plugin_package = 'zabbix-agent_iptables'
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $plugin_package = 'libiptables-zabbix-agent'
    }
  }
  package { $plugin_package :
    ensure   => present,
    require  => Package['zabbix-agent'],
  }
}

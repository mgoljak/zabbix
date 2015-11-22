#
# = Class: zabbix::agent::apache
#
# This module installs zabbix apache plugin
#
class zabbix::agent::apache (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {
  case $::osfamily {
    default: {
      $plugin_package = 'zabbix-agent_httpd'
    }
    /(RedHat|redhat|amazon)/: {
      $plugin_package = 'zabbix-agent_httpd'
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $plugin_package = 'libapache-zabbix-agent'
    }
  }
  package { 'zabbix-agent_httpd':
    ensure   => present,
    name     => $plugin_package,
    require  => Package['zabbix-agent'],
  }

  file { "${::apache::confd_dir}/server-status.conf": ensure => file, }
  file { '/etc/zabbix/zabbix_agentd.d/httpd.conf'   : ensure => file, }

}

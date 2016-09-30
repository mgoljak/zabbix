#
# = Class: zabbix::agent::pkgupgrades
#
# This module installs zabbix plugin for counting pending upgrades
#
class zabbix::agent::pkgupgrades (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  case $::osfamily {
    default: {}
    /(RedHat|redhat|amazon)/: {
      file { "${dir_zabbix_agentd_confd}/pkgupgrades.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/pkgupgrades-rhel.conf.erb'),
        notify  => Service['zabbix-agent'],
      }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      package { 'update-notifier-common':
        ensure  => present,
      }
      file { "${dir_zabbix_agentd_confd}/pkgupgrades.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/pkgupgrades-debian.conf.erb'),
        notify  => Service['zabbix-agent'],
      }
    }
  }
}

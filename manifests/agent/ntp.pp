#
# = Class: zabbix::agent::ntp
#
# This module installs zabbix ntp plugin
#
class zabbix::agent::ntp (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  case $::osfamily {
    default: {
      $ntpq_bin = '/usr/sbin/ntpq'
    }
    /(RedHat|redhat|amazon)/: {
      $ntpq_bin = '/usr/sbin/ntpq'
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $ntpq_bin = '/usr/bin/ntpq'
    }
  }

  file { "${dir_zabbix_agentd_confd}/ntp.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/ntp.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

}

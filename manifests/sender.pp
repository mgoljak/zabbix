#
# Class: zabbix::sender
#
# This module manages zabbix-sender
#
class zabbix::sender (
  $package = $::zabbix::params::sender_package,
  $version = $::zabbix::params::sender_version,
) inherits zabbix::params {

  package { 'zabbix-sender':
    ensure => $version,
    name   => $package,
  }

}

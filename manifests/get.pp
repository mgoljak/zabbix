#
# Class: zabbix::get
#
# This module manages zabbix-get
#
class zabbix::get (
  $package = $::zabbix::params::get_package,
  $version = $::zabbix::params::get_version,
) inherits zabbix::params {

  package { 'zabbix-get':
    ensure => $version,
    name   => $package,
  }

}

#
# = Class: zabbix::server::java
#
# This module manages Zabbix Java (JMX) Gateway
#
class zabbix::server::java (
  $package                 = $::zabbix::params::java_gateway_package,
  $version                 = $::zabbix::params::java_gateway_version,
  $service                 = $::zabbix::params::java_gateway_service,
  $status                  = $::zabbix::params::java_gateway_status,
  $file_owner              = $::zabbix::params::java_gateway_file_owner,
  $file_group              = $::zabbix::params::java_gateway_file_group,
  $file_mode               = $::zabbix::params::java_gateway_file_mode,
  $file_zabbix_javagw_conf = $::zabbix::params::file_zabbix_javagw_conf,
) inherits zabbix::params {

  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package[$package],
    notify  => Service[$service],
  }

  package { 'zabbix-java-gateway':
    ensure => $version,
    name   => $package,
  }

  service { 'zabbix-java-gateway':
    ensure   => running,
    name     => $service,
    enable   => true,
    require  => Package['zabbix-java-gateway'],
  }

  file { 'zabbix_java_gateway.conf':
    path    => $file_zabbix_javagw_conf,
    mode    => '0644',
    content => template('zabbix/zabbix_java_gateway.conf.erb'),
    require => Package['zabbix-java-gateway'],
    notify  => Service['zabbix-java-gateway'],
  }

}

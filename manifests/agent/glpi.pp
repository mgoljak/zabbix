#
# = Class: zabbix::agent::glpi
#
# This module installs Zabbix GLPI sensor
#
class zabbix::agent::glpi (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $glpi_url                = 'https://localhost/glpi',
  $glpi_username           = 'api',
  $glpi_password           = 'api',
  $zabbix_url              = 'https://localhost/zabbix',
  $zabbix_username         = 'api',
  $zabbix_password         = 'api',
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/glpi.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/glpi.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/glpi_to_zabbix_api.py"],
      Package['pyzabbix'],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/glpi_to_zabbix_api.py" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/glpi/glpi_to_zabbix_api.py',
  }

  package { 'python-pip':
    ensure =>  present
  }

  file { '/usr/bin/pip-python':
    ensure => 'link',
    target =>  '/usr/bin/pip',
  }

  package { 'pyzabbix':
    ensure   => present,
    provider => 'pip',
    require  =>  [ Package['python-pip'], File['/usr/bin/pip-python'], ],
  }

}

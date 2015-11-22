#
# Class: zabbix::agent
#
# This module manages zabbix-agent
#
class zabbix::agent (
  $package                 = $::zabbix::params::agent_package,
  $version                 = $::zabbix::params::agent_version,
  $service                 = $::zabbix::params::agent_service,
  $status                  = $::zabbix::params::agent_status,
  $file_owner              = $::zabbix::params::agent_file_owner,
  $file_group              = $::zabbix::params::agent_file_group,
  $file_mode               = $::zabbix::params::agent_file_mode,
  $purge_conf_dir          = $::zabbix::params::agent_purge_conf_dir,
  $file_zabbix_agentd_conf = $::zabbix::params::file_zabbix_agentd_conf,
  $dir_zabbix_agentd_confd = $::zabbix::params::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::params::dir_zabbix_agent_libdir,
  $zabbix_agentd_logfile   = $::zabbix::params::zabbix_agentd_logfile,
  $server_name             = 'mon',
  $server_active           = 'mon',
  $client_name             = $::fqdn,
  $timeout                 = '30',
  $autoload_configs        = false,
) inherits zabbix::params {

  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package['zabbix-agent'],
    notify  => Service[$service],
  }

  package { $package :
    ensure => $version,
    alias  => 'zabbix-agent',
  }

  service { 'zabbix-agent':
    ensure   => running,
    name     => $service,
    enable   => true,
    require  => Package['zabbix-agent'],
  }

  file { 'zabbix_agentd.conf':
    path    => $file_zabbix_agentd_conf,
    content => template('zabbix/zabbix_agentd.conf.erb'),
  }

  file { 'zabbix_agent_confd':
    ensure  => directory,
    path    => $dir_zabbix_agentd_confd,
    recurse => $purge_conf_dir,
    purge   => $purge_conf_dir,
  }

  file { 'zabbix_agent_libdir':
    ensure => directory,
    path   => $dir_zabbix_agent_libdir,
  }

  # enable zabbix plugins to run sudo
  ::sudoers::requiretty { 'zabbix_notty':
    requiretty => false,
    user       => 'zabbix',
    comment    => 'Allow user zabbix to run sudo without tty',
  }

  # compatibilty needed for zabbix agent sensors (sudoers)
  group { 'zabbix':
    require => Package['zabbix-agent'],
  }

  user { 'zabbix':
    require => Package['zabbix-agent'],
  }

  # autoload configs from zabbix::agent::configs from hiera
  if ( $autoload_configs == true ) {
    $zabbix_agent_config_rules = hiera_hash('zabbix::agent::configs', {})
    create_resources(::Zabbix::Agent::Config, $zabbix_agent_config_rules)
  }

}

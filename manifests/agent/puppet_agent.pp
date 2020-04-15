#
# Class: zabbix::agent::puppet_agent
#
# This module installs Puppet agent sensor
#
class zabbix::agent::puppet_agent (

  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,

) inherits zabbix::agent {

  sudoers::allowed_command { 'zabbix_puppet_agent' :
    command          => "${dir_zabbix_agent_libdir}/puppet_agent",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring Puppet agent.',
  }

  file { "${dir_zabbix_agentd_confd}/puppet_agent.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/puppet_agent.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/puppet_agent" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('zabbix/agent/puppet_agent.erb'),
    notify  => Service['zabbix-agent'],
    require => ::Sudoers::Allowed_command['zabbix_puppet_agent'],
  }

}

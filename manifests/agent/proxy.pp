#
# = Class: zabbix::agent::proxy
#
# This module installs zabbix proxy monitoring plugin
#
class zabbix::agent::proxy (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_proxy':
    command          => '/usr/bin/php /var/www/merlin/2017-2018/local/ceu/test_proxy.php',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring proxy.',
  }

  file { "${dir_zabbix_agentd_confd}/proxy.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/proxy.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => ::Sudoers::Allowed_command['zabbix_proxy'],
  }

  file { "${dir_zabbix_agent_libdir}/proxy.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/proxy.pl',
    notify  => Service['zabbix-agent'],
    require => ::Sudoers::Allowed_command['zabbix_proxy'],
  }

}

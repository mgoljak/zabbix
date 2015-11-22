#
# = Class: zabbix::agent::lld
#
# Adds some standard Low Level Discovery items
#
class zabbix::agent::lld (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_multipath':
    command          => '/sbin/multipath',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix LLD blockdev.',
  }

  file { "${dir_zabbix_agentd_confd}/lld.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/lld/lld.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/lld-blockdev" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/lld/lld-blockdev',
    notify  => Service['zabbix-agent'],
    require => ::Sudoers::Allowed_command['zabbix_sudo_multipath'],
  }

}

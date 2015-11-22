#
# = Class: zabbix::agent::ssh
#
# This module installs zabbix ssh plugin
#
class zabbix::agent::ssh (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  case $::osfamily {
    default: {
      $lsof_bin = '/usr/sbin/lsof'
    }
    /(RedHat|redhat|amazon)/: {
      $lsof_bin = '/usr/sbin/lsof'
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $lsof_bin = '/usr/bin/lsof'
    }
  }

  ::sudoers::allowed_command { 'zabbix_ssh':
    command          => "${lsof_bin} -i -n -l -P",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring SSH.',
  }

  file { "${dir_zabbix_agentd_confd}/ssh.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/ssh.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => ::Sudoers::Allowed_command['zabbix_ssh'],
  }

}

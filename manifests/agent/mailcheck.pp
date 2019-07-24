#
# = Class: zabbix::agent::mailcheck
#
# This module installs zabbix mailcheck sensor
#
class zabbix::agent::mailcheck (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $mail_host               = 'imap.srce.hr',
  $mail_username           = '',
  $mail_password           = '',
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/mailcheck.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mailcheck.conf.erb'),
    notify  => Service['zabbix-agent'],
    #require => [ Package['php-cli'] ],
  }

  file { "${dir_zabbix_agent_libdir}/mail_check.php":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/mail_check.php',
  }

  file { "${dir_zabbix_agent_libdir}/mail_send.php":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/mail_send.php',
  }

}

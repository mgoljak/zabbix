#
# = Class: zabbix::agent::tomcatdir
#
# This module installs Tomcat Git Repo sensor
#
class zabbix::agent::tomcatdir (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/tomcatdir.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/tomcatdir.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/tomcat-dir.jar"],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/tomcat-dir.jar" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/tomcatdir/tomcat-dir.jar',
  }

}

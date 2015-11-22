#
# = Class: zabbix::agent::nfsclient
#
# This module installs NFS client monitoring plugin
#
class zabbix::agent::nfsclient (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {


  file { "${dir_zabbix_agentd_confd}/nfsclient.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/nfsclient.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

#  file { "${dir_zabbix_agent_libdir}/proxy.pl" :
#    ensure  => file,
#    owner   => root,
#    group   => root,
#    mode    => '0755',
#    source  => 'puppet:///modules/zabbix/agent/proxy.pl',
#    notify  => Service['zabbix-agent'],
#    require => ::Sudoers::Allowed_command['zabbix_proxy'],
#  }

}

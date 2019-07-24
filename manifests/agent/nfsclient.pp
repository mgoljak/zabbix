#
# = Class: zabbix::agent::nfsclient
#
# This module installs NFS client monitoring plugin
#
class zabbix::agent::nfsclient (
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_for_monitoring = $::zabbix::agent::dir_for_monitoring,
) inherits zabbix::agent {

    if $dir_for_monitoring {
      file { "${dir_zabbix_agentd_confd}/nfsclient.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('zabbix/agent/nfsclient.conf.erb'),
        notify  => Service['zabbix-agent'],
      }
    }

    else {
      notify{'!!! zabbix::agent::dir_for_monitoring must be included defined !!!': }
    }

}

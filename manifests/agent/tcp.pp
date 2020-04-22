#
# = Class: zabbix::agent::tcp
#
# Add module for TCP connections
#
class zabbix::agent::tcp (
  $dir_zabbix_agentd_confd  = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_modules = $::zabbix::agent::dir_zabbix_agent_modules,
  $module                   = "puppet:///modules/zabbix/agent/modules/${facts[os][family]}/${facts[os][release][major]}/tcp_count.so"
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/tcp.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/tcp.conf',
    notify  => Service['zabbix-agent'],
    require => [ Package['zabbix-agent'], File["${dir_zabbix_agent_modules}/tcp_count.so"] ],
  }

  file { "${dir_zabbix_agent_modules}/tcp_count.so" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => $module,
    notify => Service['zabbix-agent'],
  }
}

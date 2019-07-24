#
# = Class: zabbix::agent::gpu
#
# This module installs Zabbix GPU sensor
#
class zabbix::agent::gpu (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/gpu.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/gpu.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/get_gpu_info"],
      File["${dir_zabbix_agent_libdir}/get_gpus_info.sh"],
      Package['python35u'],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/get_gpu_info" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/gpu/get_gpu_info',
  }

  file { "${dir_zabbix_agent_libdir}/get_gpus_info.sh" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/gpu/get_gpus_info.sh',
  }

}

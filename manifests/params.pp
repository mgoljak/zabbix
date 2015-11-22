#
# Class: zabbix::params
#
# This module contains defaults for other zabbix modules
#
class zabbix::params {

  # general zabbix settings
  $ensure         = 'present'
  $server_name    = 'mon'
  $server_active  = 'mon'
  $client_name    = $::fqdn

  # module specific settings (agent)
  $agent_file_owner     = 'root'
  $agent_file_group     = 'root'
  $agent_file_mode      = '0644'
  $agent_purge_conf_dir = false

  # module specific settings (proxy)
  $proxy_file_owner     = 'root'
  $proxy_file_group     = 'root'
  $proxy_file_mode      = '0644'
  $proxy_purge_conf_dir = false

  # module specific settings (server)
  $server_file_owner     = 'root'
  $server_file_group     = 'root'
  $server_file_mode      = '0644'
  $server_purge_conf_dir = false

  # module specific settings (java gateway)
  $java_gateway_file_owner     = 'root'
  $java_gateway_file_group     = 'root'
  $java_gateway_file_mode      = '0644'

  # module dependencies
  $dependency_class = 'zabbix::dependency'
  $my_class         = undef

  # install package depending on major version
  case $::osfamily {
    default: {
      $agent_package            = 'zabbix-agent'
      $agent_version            = 'present'
      $agent_service            = 'zabbix-agent'
      $agent_status             = 'enabled'
      $file_zabbix_agentd_conf  = '/etc/zabbix/zabbix_agentd.conf'
      $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agentd.d'
      $dir_zabbix_agent_libdir  = '/usr/lib/zabbix/agent'
      $zabbix_agentd_logfile    = '/var/log/zabbix/zabbix_agentd.log'
      $server_package           = 'zabbix-server'
      $server_version           = 'present'
      $server_service           = 'zabbix-server'
      $server_status            = 'enabled'
      $zabbix_server_logfile    = '/var/log/zabbix/zabbix_server.log'
      $zabbix_server_pidfile    = '/var/run/zabbix/zabbix_server.pid'
      $fpinglocation            = '/usr/bin/fping'
      $fping6location           = '/usr/bin/fping6'
      $alert_scripts_path       = '/var/lib/zabbixsrv/alertscripts'
      $file_zabbix_server_conf  = '/etc/zabbix/zabbix_server.conf'
      $dir_zabbix_server_confd  = '/etc/zabbix/zabbix_server.d'
      $external_scripts         = '/var/lib/zabbixsrv/externalscripts'
      $tmpdir                   = '/tmp'
      $proxy_package            = 'zabbix-proxy'
      $proxy_version            = 'present'
      $proxy_service            = 'zabbix-proxy'
      $proxy_status             = 'enabled'
      $java_gateway_package     = 'zabbix-java-gateway'
      $java_gateway_version     = 'present'
      $java_gateway_service     = 'zabbix-java-gateway'
      $java_gateway_status      = 'enabled'
      $file_zabbix_javagw_conf  = '/etc/zabbix/zabbix_java_gateway.conf'
      $web_package              = 'zabbix-web'
      $web_version              = 'present'
      $web_file_owner           = 'root'
      $web_file_group           = 'root'
      $web_file_mode            = '0640'
      $web_dir_zabbix_php       = '/etc/zabbix/web'
    }
    /(RedHat|redhat|amazon)/: {
      $agent_package            = 'zabbix-agent'
      $agent_version            = 'present'
      $agent_service            = 'zabbix-agent'
      $agent_status             = 'enabled'
      $file_zabbix_agentd_conf  = '/etc/zabbix/zabbix_agentd.conf'
      $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agentd.d'
      $dir_zabbix_agent_libdir  = '/usr/libexec/zabbix-agent'
      $zabbix_agentd_logfile    = '/var/log/zabbix/zabbix_agentd.log'
      $server_package           = 'zabbix-server'
      $server_version           = 'present'
      $server_service           = 'zabbix-server'
      $server_status            = 'enabled'
      $zabbix_server_logfile    = '/var/log/zabbixsrv/zabbix_server.log'
      $zabbix_server_pidfile    = '/var/run/zabbixsrv/zabbix_server.pid'
      $fpinglocation            = '/usr/sbin/fping'
      $fping6location           = '/usr/sbin/fping6'
      $alert_scripts_path       = '/var/lib/zabbixsrv/alertscripts'
      $external_scripts         = '/var/lib/zabbixsrv/externalscripts'
      $tmpdir                   = '/var/lib/zabbixsrv/tmp'
      $file_zabbix_server_conf  = '/etc/zabbix/zabbix_server.conf'
      $dir_zabbix_server_confd  = '/etc/zabbix/zabbix_server.d'
      $proxy_package            = 'zabbix-proxy'
      $proxy_version            = 'present'
      $proxy_service            = 'zabbix-proxy'
      $proxy_status             = 'enabled'
      $java_gateway_package     = 'zabbix-java-gateway'
      $java_gateway_version     = 'present'
      $java_gateway_service     = 'zabbix-java-gateway'
      $java_gateway_status      = 'enabled'
      $file_zabbix_javagw_conf  = '/etc/zabbix/zabbix_java_gateway.conf'
      $web_package              = 'zabbix-web'
      $web_version              = 'present'
      $web_file_owner           = 'root'
      $web_file_group           = 'apache'
      $web_file_mode            = '0640'
      $web_dir_zabbix_php       = '/etc/zabbix/web'
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $agent_package            = 'zabbix-agent'
      $agent_version            = 'present'
      $agent_service            = 'zabbix-agent'
      $agent_status             = 'enabled'
      $file_zabbix_agentd_conf  = '/etc/zabbix/zabbix_agentd.conf'
      $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agentd.conf.d'
      $dir_zabbix_agent_libdir  = '/usr/lib/zabbix-agent'
      $zabbix_agentd_logfile    = '/var/log/zabbix-agent/zabbix_agentd.log'
      $server_package           = 'zabbix-server'
      $server_version           = 'present'
      $server_service           = 'zabbix-server'
      $server_status            = 'enabled'
      $zabbix_server_logfile    = '/var/log/zabbix/zabbix_server.log'
      $zabbix_server_pidfile    = '/var/run/zabbix/zabbix_server.pid'
      $fpinglocation            = '/usr/bin/fping'
      $fping6location           = '/usr/bin/fping6'
      $alert_scripts_path       = '/usr/lib/zabbix/alertscripts'
      $external_scripts         = '/usr/lib/zabbix/externalscripts'
      $tmpdir                   = '/tmp'
      $file_zabbix_server_conf  = '/etc/zabbix/zabbix_server.conf'
      $dir_zabbix_server_confd  = '/etc/zabbix/zabbix_server.d'
      $proxy_package            = 'zabbix-proxy'
      $proxy_version            = 'present'
      $proxy_service            = 'zabbix-proxy'
      $proxy_status             = 'enabled'
      $java_gateway_package     = 'zabbix-java-gateway'
      $java_gateway_version     = 'present'
      $java_gateway_service     = 'zabbix-java-gateway'
      $java_gateway_status      = 'enabled'
      $file_zabbix_javagw_conf  = '/etc/zabbix/zabbix_java_gateway.conf'
      $web_package              = 'zabbix-frontend-php'
      $web_version              = 'present'
      $web_file_owner           = 'root'
      $web_file_group           = 'www-data'
      $web_file_mode            = '0640'
      $web_dir_zabbix_php       = '/etc/zabbix/web'
    }
  }

}

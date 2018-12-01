#
# Class: zabbix::proxy
#
# This module manages zabbix-proxy
#
class zabbix::proxy (
  $package                 = $::zabbix::params::proxy_package,
  $version                 = $::zabbix::params::proxy_version,
  $service                 = $::zabbix::params::proxy_service,
  $status                  = $::zabbix::params::proxy_status,
  $file_owner              = $::zabbix::params::proxy_file_owner,
  $file_group              = $::zabbix::params::proxy_file_group,
  $file_mode               = $::zabbix::params::proxy_file_mode,
  $file_zabbix_proxy_conf  = $::zabbix::params::file_zabbix_proxy_conf,
  $erb_zabbix_proxy_conf   = 'zabbix/zabbix_proxy.conf.erb',
  $proxymode               = '0',
  $pidfile                 = $::zabbix::params::proxy_pidfile,
  $logfile                 = $::zabbix::params::proxy_logfile,
  $listenip                = '0.0.0.0',
  $create_db               = false,
  $db                      = 'pgsql',
  $dbhost                  = 'localhost',
  $dbname                  = 'zabbix',
  $dbuser                  = 'zabbix',
  $dbpass                  = 'secret',
  $dbsocket                = false,
  $dbsocket_path           = '/var/lib/mysql/mysql.sock',
  $server                  = '127.0.0.1',
  $client_name             = $::fqdn,
  $tls_connect             = 'unencrypted',
  $tls_accept              = 'unencrypted',
  $tls_ca_file             = undef,
  $tls_cert_file           = undef,
  $tls_key_file            = undef,
) inherits zabbix::params {

  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package['zabbix-proxy'],
    notify  => Service['zabbix-proxy'],
  }

  package { 'zabbix-proxy':
    ensure => $version,
    name   => "${package}-${db}",
  }

  service { 'zabbix-proxy':
    ensure  => running,
    name    => $service,
    enable  => true,
    require => Package['zabbix-proxy'],
  }

  file { 'zabbix_proxy.conf':
    path    => $file_zabbix_proxy_conf,
    mode    => '0640',
    content => template($erb_zabbix_proxy_conf),
  }

#  file { '/etc/zabbix/zabbix_server.d':
#    ensure  => directory,
#    path    => $dir_zabbix_server_confd,
#    recurse => $purge_conf_dir,
#    purge   => $purge_conf_dir,
#  }

  if $dbhost == 'localhost' and $create_db == true {
    case $db {
      default : { }
      'pgsql': {
        include ::postgresql::client
        include ::postgresql::server
        ::postgresql::server::db { $dbname:
          user     => $dbuser,
          password => postgresql_password($dbuser,$dbpass),
        }
        ::postgresql::server::pg_hba_rule { 'zabbix_localhost':
          type        => 'host',
          database    => 'zabbix',
          user        => 'zabbix',
          auth_method => 'md5',
          address     => '127.0.0.1/32',
          description => 'Allow user zabbix to access database from localhost',
        }
      }
      'mysql': {
        include ::mysql::server
        ::mysql::db { $dbname:
          user     => $dbuser,
          password => $dbpass,
          host     => 'localhost',
          grant    => ['all'],
        }
      }
    }
  }

#  # autoload configs from zabbix::server::configs from hiera
#  if ( $autoload_configs == true ) {
#    $zabbix_config_rules = hiera_hash('zabbix::server::configs', {})
#    create_resources(::zabbix::server::config, $zabbix_config_rules)
#  }

}

#
# Class: zabbix::server
#
# This module manages zabbix-server
#
class zabbix::server (
  $package                 = $::zabbix::params::server_package,
  $version                 = $::zabbix::params::server_version,
  $service                 = $::zabbix::params::server_service,
  $status                  = $::zabbix::params::server_status,
  $file_owner              = $::zabbix::params::server_file_owner,
  $file_group              = $::zabbix::params::server_file_group,
  $file_mode               = $::zabbix::params::server_file_mode,
  $purge_conf_dir          = $::zabbix::params::server_purge_conf_dir,
  $file_zabbix_server_conf = $::zabbix::params::file_zabbix_server_conf,
  $dir_zabbix_server_confd = $::zabbix::params::dir_zabbix_server_confd,
  $pidfile                 = $::zabbix::params::zabbix_server_pidfile,
  $logfile                 = $::zabbix::params::zabbix_server_logfile,
  $listenip                = '0.0.0.0',
  $create_db               = false,
  $db                      = 'pgsql',
  $dbhost                  = 'localhost',
  $dbname                  = 'zabbix',
  $dbuser                  = 'zabbix',
  $dbpass                  = 'secret',
  $dbsocket                = false,
  $dbsocket_path           = '/var/lib/mysql/mysql.sock',
  $fpinglocation           = $::zabbix::params::fpinglocation,
  $fping6location          = $::zabbix::params::fping6location,
  $alert_scripts_path      = $::zabbix::params::alert_scripts_path,
  $external_scripts        = $::zabbix::params::external_scripts,
  $tmpdir                  = $::zabbix::params::tmpdir,
  $autoload_configs        = false,
) inherits zabbix::params {

  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package['zabbix-server'],
    notify  => Service['zabbix-server'],
  }

  package { 'zabbix-server':
    ensure => $version,
    name   => "${package}-${db}",
  }

  service { 'zabbix-server':
    ensure   => running,
    name     => $service,
    enable   => true,
    require  => Package['zabbix-server'],
  }

  file { 'zabbix_server.conf':
    path    => $file_zabbix_server_conf,
    mode    => '0640',
    content => template('zabbix/zabbix_server.conf.erb'),
  }

  file { '/etc/zabbix/zabbix_server.d':
    ensure  => directory,
    path    => $dir_zabbix_server_confd,
    recurse => $purge_conf_dir,
    purge   => $purge_conf_dir,
  }

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
        include ::mysql::client
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

  # autoload configs from zabbix::server::configs from hiera
  if ( $autoload_configs == true ) {
    $zabbix_config_rules = hiera_hash('zabbix::server::configs', {})
    create_resources(::Zabbix::Server::Config, $zabbix_config_rules)
  }

}

#
# = Class: zabbix::web
#
# This module manages zabbix-web
#
class zabbix::web (
  $package            = $::zabbix::params::web_package,
  $version            = $::zabbix::params::web_version,
  $file_owner         = $::zabbix::params::web_file_owner,
  $file_group         = $::zabbix::params::web_file_group,
  $file_mode          = $::zabbix::params::web_file_mode,
  $dir_zabbix_php     = $::zabbix::params::web_dir_zabbix_php,
  $db                 = 'mysql',
  $dbhost             = 'localhost',
  $dbport             = '3306',
  $dbname             = 'zabbix',
  $dbuser             = 'zabbix',
  $dbpass             = 'secret',
  $server_host        = 'localhost',
  $server_port        = '10051',
  $server_name        = '',
  $image_format       = 'IMAGE_FORMAT_PNG',
  $manage_maintenance = true,
  $maintenance_mode   = false,
  $maintenance_ip     = [ '127.0.0.1' ],
  $manage_apache      = true,
  $manage_php         = false,
) inherits zabbix::params {

  # depends on puppetlabs/apache
  if ( $manage_apache ) {
    include ::apache
    include ::apache::mod::php
    include ::apache::mod::rewrite

    file { "${::apache::confd_dir}/zabbix.conf":
      content => template('zabbix/zabbix.conf.erb'),
      require => Package['zabbix-web'],
    }
  }

  # depends on jsosic/php module
  if ( $manage_php ) { ::php::mod { 'pgsql': ensure => present } }

  File {
    ensure  => file,
    require => Package[$package],
  }

  package { 'zabbix-web':
    ensure => $version,
    name   => $package,
  }

  file { "${dir_zabbix_php}/zabbix.conf.php":
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    content => template('zabbix/zabbix.conf.php.erb'),
  }

  if $manage_maintenance {
    file { "${dir_zabbix_php}/maintenance.inc.php":
      owner   => $file_owner,
      group   => $file_group,
      mode    => $file_mode,
      content => template('zabbix/maintenance.inc.php.erb'),
    }
  }

}

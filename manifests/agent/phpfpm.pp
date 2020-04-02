#
# = Class: zabbix::agent::phpfpm
#
# This module installs Zabbix php-fpm sensor
#
class zabbix::agent::phpfpm (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $php_fpm_sock            = undef,
) inherits zabbix::agent {

  case $::osfamily {
    default: {
      $cgi_fcgi = 'fcgi'
      if $php_fpm_sock == undef {
        $php_fpm_sock = '127.0.0.1:9000'
      }
    }
    /(RedHat|redhat|amazon)/: {
      $cgi_fcgi = 'fcgi'
      if $php_fpm_sock == undef {
        if $::facts['os']['release']['major'] == '8' {
          $php_fpm_sock = '/run/php-fpm/www.sock'
        }
        else {
          $php_fpm_sock = '127.0.0.1:9000'
        }
      }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $cgi_fcgi = 'libcgi-bin'
      if $php_fpm_sock == undef {
        if $::facts['os']['release']['major'] == '10' {
          $php_fpm_sock = '/run/php/php7.3-fpm.sock'
        }
        else {
          $php_fpm_sock = '/run/php/php7.0-fpm.sock'
        }
      }
    }
  }

  package { 'cgi-fcgi' :
    ensure =>  present,
    name   => $cgi_fcgi,
  }

  ::sudoers::allowed_command { 'zabbix_php-fpm':
    command          => "${dir_zabbix_agent_libdir}/php-fpm.sh",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring php-fpm.',
  }

  file { "${dir_zabbix_agentd_confd}/php-fpm.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/php-fpm.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/php-fpm.sh"],
      Package['fcgi'],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/php-fpm.sh" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('zabbix/agent/php-fpm.sh.erb'),
  }

}

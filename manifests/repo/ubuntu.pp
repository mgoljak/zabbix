#
# = Class: zabbix::repo::ubuntu
#
class zabbix::repo::ubuntu (
  $version = '2.2',
) {

  include ::apt
  ::apt::source { 'zabbix':
    location          => "http://repo.zabbix.com/zabbix/${version}/ubuntu",
    release           => $::lsbdistcodename,
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => '79EA5ED4',
    key_server        => 'pgp.mit.edu',
    include_src       => false,
  }

}

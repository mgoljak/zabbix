#!/usr/bin/perl
#
# Sensor for gathering Apache performance data for Zabbix via
# apache mod_status.
# Copyright (c) 2009 Jakov Sosic
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Changes and Modifications
# * Tue Jun 28 16:26:18 CEST 2011
#	- fixed if to if exists in $inputstring
# * Wed Dec 30 00:18:43 CET 2009
# 	- fixed issues if mod_status gives partial information
# * Fri May  1 21:09:16 CEST 2009
# 	- rewritten sender to use only one connection
# 	- fixed alarms
# * Thu May 15 03:40:39 CEST 2008
#       - script created
#

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/zabbixSenderFileMemcached";
my $zabbix_send_command="$zabbix_sender -c $zabbix_confd -i $send_file";
my $inputString = '';
my $hostname = qx("/bin/hostname");
chomp($hostname);

# signal handling
$SIG{'ALRM'} = sub {
	local $SIG{TERM} = 'IGNORE';
	kill TERM => -$$;
	print "0\n";
	exit(-1);
};

local $SIG{TERM} = sub {
	local $SIG{TERM} = 'IGNORE';
	kill TERM => -$$;
	print "0\n";
	exit(-1);
};

alarm 25;

# fetch status from cmd
my $cmd = "echo -e 'stats\nquit' | nc 127.0.0.1 11211";
my $output = qx($cmd);
##print $output;

# get information from status output
my($accepting_conns,$auth_cmds,$auth_errors,$bytes,$bytes_read,$bytes_written,$cas_badval,$cas_hits,$cas_misses,$cmd_flush,$cmd_get,$cmd_set,$connection_structures,$conn_yields,$curr_connections,$curr_items,$decr_hits,$decr_misses,$delete_hits,$delete_misses,$evictions,$get_hits,$get_misses,$incr_hits,$incr_misses,$limit_maxbytes,$listen_disabled_num,$pid,$pointer_size,$rusage_system,$rusage_user,$threads,$time,$total_connections,$total_items,$uptime,$version);

$accepting_conns         = $1 if ($output =~ /STAT\s+accepting_conns\s+(\d+)/i);
$auth_cmds               = $1 if ($output =~ /STAT\s+auth_cmds\s+(\d+)/i);
$auth_errors             = $1 if ($output =~ /STAT\s+auth_errors\s+(\d+)/i);
$bytes                   = $1 if ($output =~ /STAT\s+bytes\s+(\d+)/i);
$bytes_read              = $1 if ($output =~ /STAT\s+bytes_read\s+(\d+)/i);
$bytes_written           = $1 if ($output =~ /STAT\s+bytes_written\s+(\d+)/i);
$cas_badval              = $1 if ($output =~ /STAT\s+cas_badval\s+(\d+)/i);
$cas_hits                = $1 if ($output =~ /STAT\s+cas_hits\s+(\d+)/i);
$cas_misses              = $1 if ($output =~ /STAT\s+cas_misses\s+(\d+)/i);
$cmd_flush               = $1 if ($output =~ /STAT\s+cmd_flush\s+(\d+)/i);
$cmd_get                 = $1 if ($output =~ /STAT\s+cmd_get\s+(\d+)/i);
$cmd_set                 = $1 if ($output =~ /STAT\s+cmd_set\s+(\d+)/i);
$connection_structures   = $1 if ($output =~ /STAT\s+connection_structures\s+(\d+)/i);
$conn_yields             = $1 if ($output =~ /STAT\s+conn_yields\s+(\d+)/i);
$curr_connections        = $1 if ($output =~ /STAT\s+curr_connections\s+(\d+)/i);
$curr_items              = $1 if ($output =~ /STAT\s+curr_items\s+(\d+)/i);
$decr_hits               = $1 if ($output =~ /STAT\s+decr_hits\s+(\d+)/i);
$decr_misses             = $1 if ($output =~ /STAT\s+decr_misses\s+(\d+)/i);
$delete_hits             = $1 if ($output =~ /STAT\s+delete_hits\s+(\d+)/i);
$delete_misses           = $1 if ($output =~ /STAT\s+delete_misses\s+(\d+)/i);
$evictions               = $1 if ($output =~ /STAT\s+evictions\s+(\d+)/i);
$get_hits                = $1 if ($output =~ /STAT\s+get_hits\s+(\d+)/i);
$get_misses              = $1 if ($output =~ /STAT\s+get_misses\s+(\d+)/i);
$incr_hits               = $1 if ($output =~ /STAT\s+incr_hits\s+(\d+)/i);
$incr_misses             = $1 if ($output =~ /STAT\s+incr_misses\s+(\d+)/i);
$limit_maxbytes          = $1 if ($output =~ /STAT\s+limit_maxbytes\s+(\d+)/i);
$listen_disabled_num     = $1 if ($output =~ /STAT\s+listen_disabled_num\s+(\d+)/i);
$pid                     = $1 if ($output =~ /STAT\s+pid\s+(\d+)/i);
$pointer_size            = $1 if ($output =~ /STAT\s+pointer_size\s+(\d+)/i);
$rusage_system           = $1 if ($output =~ /STAT\s+rusage_system\s+([\d|\.]+)/i);
$rusage_user             = $1 if ($output =~ /STAT\s+rusage_user\s+([\d|\.]+)/i);
$threads                 = $1 if ($output =~ /STAT\s+threads\s+(\d+)/i);
$time                    = $1 if ($output =~ /STAT\s+time\s+(\d+)/i);
$total_connections       = $1 if ($output =~ /STAT\s+total_connections\s+(\d+)/i);
$total_items             = $1 if ($output =~ /STAT\s+total_items\s+(\d+)/i);
$uptime                  = $1 if ($output =~ /STAT\s+uptime\s+(\d+)/i);
$version                 = $1 if ($output =~ /STAT\s+version\s+([\d|\.]+)/i);

#print $auth_cmds;
#print $auth_errors;

# write data to variable
$inputString .= $hostname ." memcached.accepting_conns "         . $accepting_conns         ."\n" if $accepting_conns ne '';
$inputString .= $hostname ." memcached.auth_cmds "               . $auth_cmds               ."\n" if $auth_cmds ne '';
$inputString .= $hostname ." memcached.auth_errors "             . $auth_errors             ."\n" if $auth_errors ne '';
$inputString .= $hostname ." memcached.bytes "                   . $bytes                   ."\n" if $bytes ne '';
$inputString .= $hostname ." memcached.bytes_read "              . $bytes_read              ."\n" if $bytes_read ne '';
$inputString .= $hostname ." memcached.bytes_written "           . $bytes_written           ."\n" if $bytes_written ne '';
$inputString .= $hostname ." memcached.cas_badval "              . $cas_badval              ."\n" if $cas_badval ne '';
$inputString .= $hostname ." memcached.cas_hits "                . $cas_hits                ."\n" if $cas_hits ne '';
$inputString .= $hostname ." memcached.cas_misses "              . $cas_misses              ."\n" if $cas_misses ne '';
$inputString .= $hostname ." memcached.cmd_flush "               . $cmd_flush               ."\n" if $cmd_flush ne '';
$inputString .= $hostname ." memcached.cmd_get "                 . $cmd_get                 ."\n" if $cmd_get ne '';
$inputString .= $hostname ." memcached.cmd_set "                 . $cmd_set                 ."\n" if $cmd_set ne '';
$inputString .= $hostname ." memcached.connection_structures "   . $connection_structures   ."\n" if $connection_structures ne '';
$inputString .= $hostname ." memcached.conn_yields "             . $conn_yields             ."\n" if $conn_yields ne '';
$inputString .= $hostname ." memcached.curr_connections "        . $curr_connections        ."\n" if $curr_connections ne '';
$inputString .= $hostname ." memcached.curr_items "              . $curr_items              ."\n" if $curr_items ne '';
$inputString .= $hostname ." memcached.decr_hits "               . $decr_hits               ."\n" if $decr_hits ne '';
$inputString .= $hostname ." memcached.decr_misses "             . $decr_misses             ."\n" if $decr_misses ne '';
$inputString .= $hostname ." memcached.delete_hits "             . $delete_hits             ."\n" if $delete_hits ne '';
$inputString .= $hostname ." memcached.delete_misses "           . $delete_misses           ."\n" if $delete_misses ne '';
$inputString .= $hostname ." memcached.evictions "               . $evictions               ."\n" if $evictions ne '';
$inputString .= $hostname ." memcached.get_hits "                . $get_hits                ."\n" if $get_hits ne '';
$inputString .= $hostname ." memcached.get_misses "              . $get_misses              ."\n" if $get_misses ne '';
$inputString .= $hostname ." memcached.incr_hits "               . $incr_hits               ."\n" if $incr_hits ne '';
$inputString .= $hostname ." memcached.incr_misses "             . $incr_misses             ."\n" if $incr_misses ne '';
$inputString .= $hostname ." memcached.limit_maxbytes "          . $limit_maxbytes          ."\n" if $limit_maxbytes ne '';
$inputString .= $hostname ." memcached.listen_disabled_num "     . $listen_disabled_num     ."\n" if $listen_disabled_num ne '';
$inputString .= $hostname ." memcached.pid "                     . $pid                     ."\n" if $pid ne '';
$inputString .= $hostname ." memcached.pointer_size "            . $pointer_size            ."\n" if $pointer_size ne '';
$inputString .= $hostname ." memcached.rusage_system "           . $rusage_system           ."\n" if $rusage_system ne '';
$inputString .= $hostname ." memcached.rusage_user "             . $rusage_user             ."\n" if $rusage_user ne '';
$inputString .= $hostname ." memcached.threads "                 . $threads                 ."\n" if $threads ne '';
$inputString .= $hostname ." memcached.time "                    . $time                    ."\n" if $time ne '';
$inputString .= $hostname ." memcached.total_connections "       . $total_connections       ."\n" if $total_connections ne '';
$inputString .= $hostname ." memcached.total_items "             . $total_items             ."\n" if $total_items ne '';
$inputString .= $hostname ." memcached.uptime "                  . $uptime                  ."\n" if $uptime ne '';
$inputString .= $hostname ." memcached.version "                 . $version                 ."\n" if $version ne '';

#print $inputString;

# write everything to file
open FH, ">", $send_file or die("Can not open file $send_file!");
print FH $inputString;
close(FH);

# finally, send the data
if ( qx($zabbix_send_command) =~ /Failed(:)? 0/i ) {
   unlink ($send_file) or die("Can not remove file $send_file!");
   print("1\n");
   exit(0);
} else {
   unlink ($send_file) or die("Can not remove file $send_file!");
   print("0\n");
   exit(-1);
}
#EOF

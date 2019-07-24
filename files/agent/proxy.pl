#!/usr/bin/perl
#
# Sensor for checking proxy connection to outside world
# Copyright (c) 2014 Dragan Janjusevic
#

use strict;
use warnings;

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/tmp/zabbixSenderFileProxy";
my $zabbix_send_command="$zabbix_sender -c $zabbix_confd -i $send_file";
my $inputString = ''; 
my $hostname = qx("/bin/hostname"); 
chomp($hostname);

# signal handling
$SIG{'ALRM'} = sub {
        local $SIG{TERM} = 'IGNORE';
        kill TERM => -$$;
        print "0\n";
};

local $SIG{TERM} = sub {
        local $SIG{TERM} = 'IGNORE';
        kill TERM => -$$;
        print "0\n";
};

alarm 25;

# data
my $key = "proxy.get";
my $cmd = "/usr/bin/sudo /usr/bin/php /var/www/merlin/2017-2018/local/ceu/test_proxy.php";
my $output = qx($cmd);
#print $output;

# write data to variable
$inputString .= $hostname ." ". $key ." ". $output;
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
# EOF

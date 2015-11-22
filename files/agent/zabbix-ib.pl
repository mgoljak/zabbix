#!/usr/bin/perl

use warnings;
use strict;

my $zabbixSender="/usr/bin/zabbix_sender";
my $zabbixConfd="/etc/zabbix/zabbix_agentd.conf";
my $sendFile="/var/tmp/zabbixSenderIB.$$";
my $zabbixSendCommand="$zabbixSender -c $zabbixConfd -i ";
my $perfqueryCommand="sudo /usr/sbin/perfquery -r";
my $perfqueryExtCommand="sudo /usr/sbin/perfquery -x -r";
my $outputString="";
my $extended = $ARGV[0];
my $interval = $ARGV[1] || 120;
$extended = 1 unless(defined $extended);

# list here parameters you want to filter
my $filterList = {
};
my $perfData = {
    PortRcvPkts  => 0,
    PortXmitPkts => 0,
    PortRcvData  => 0,
    PortXmitData => 0,
}; 

sub friendlyDie {
    my $message = shift;
    print "$message\n";
    exit -1;
}

sub processValues {
    my $value = shift;
    my $item = shift;
    if ( $item =~ /Port(Xmit|Rcv)Pkts/ ) {
        return ($perfData->{$item} + $value) / $interval;
    } elsif ( $item =~ /Port(Xmit|Rcv)Data/ ) {
        return (($perfData->{$item} + $value) * 32) / $interval;
    } else {
        return $value;
    }
}

if ($extended) {
    friendlyDie("Could not run: $perfqueryExtCommand") unless (open(CH, "$perfqueryExtCommand |"));
    foreach my $line (<CH>) {
        if ($line =~ /(\S+?)\:\.+(\d+)/) {
            $perfData->{$1} = $2 if (exists $perfData->{$1});
        }
    }
    close(CH);
}

friendlyDie("Could not run: $perfqueryCommand") unless (open(CH, "$perfqueryCommand |"));
foreach my $line (<CH>) {
    if ($line =~ /(\S+?)\:\.+(\d+)/) {
        my $item = $1;
        my $value = processValues($2, $item);
        next if ($item =~ /CounterSelect/);
        next if (exists $filterList->{$item});
        $outputString .= "- infiniband.$item $value\n";
    }
}
close(CH);

friendlyDie("Could not open file $sendFile!") unless (open(FH, ">", $sendFile));
print FH $outputString;
friendlyDie("Could not close file $sendFile!") unless (close(FH));

$zabbixSendCommand .= $sendFile;
my $sendOutput = qx($zabbixSendCommand);
friendlyDie("Can not remove file $sendFile!") unless(unlink ($sendFile));
if ( $sendOutput !~ /Failed(:)? 0/i ) {
    friendlyDie("zabbix_sender reported Failed items: $sendOutput");
}

print "Success\n";
exit 0;

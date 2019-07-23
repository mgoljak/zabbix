#!/usr/bin/perl

use XML::Simple;
use LWP::UserAgent;
use strict;
use Getopt::Long;
use JSON;

sub getHTTPData {
    my $ua = shift;
    my $url = shift;

    my $req = HTTP::Request->new(GET => $url);
    my $res = $ua->request($req);

    if (!$res->is_success) {
        die("Retrieving data failed: ".$res->status_line);
    }

    my $ref;
    eval {
        $ref = XMLin($res->content);
    };
    if ($@) {
        die("Error parsing XML response: ".$@);
    }

    return $ref;
}


sub calcAvg {
    my $writeArr = shift;
    my $writeSum = 0;
    my $writeStart = 0;
    my $writeStop = 0;

    foreach my $perfEntry (@$writeArr) {
        $writeSum += $perfEntry->{content};
        unless ($writeStart) {
            $writeStart = $perfEntry->{time};
        } else {
            $writeStart = ($perfEntry->{time}<$writeStart) ? $perfEntry->{time} : $writeStart;
        }
        unless ($writeStop) {
            $writeStop = $perfEntry->{time};
        } else {
            $writeStop  = ($perfEntry->{time}>$writeStop) ? $perfEntry->{time} : $writeStop;
        }
    }

    return 1000*$writeSum/($writeStop-$writeStart);
}

my $timeout = 30;
my $hostname = 'localhost';
my $port = 8000;
my $mount = 'mnt/fhgfs';
my $output = '';
my $conf;

if (!GetOptions (
    't=i' => \$timeout, 'timeout=i' => \$timeout,
    'H=s' => \$hostname, 'hostname=s' => \$hostname,
    'p=i' => \$port, 'port=i' => \$port,
    'm=s' => \$mount, 'mount=s' => \$mount,
    'c=s' => \$conf, 'conf=s' => \$conf,
   )) {
    die("Incorrect options. Please use zabbix-beegfs -t|--timeout -H|--hostname -p|port -c|--conf");
}

if ($conf) {
    my $zbxArray = [];
    open( FH, $conf) or die "$!\n";
    while (my $row = <FH>) {
        if ($row =~ /^(\S+?):(\S+?)$/) {
            my $ref = {'{#BEEGFS_PORT}' => $1, '{#BEEGFS_MOUNT}' => $2};
            push @{$zbxArray}, {%{$ref}};
        }
    }
    close(FH);
    print to_json({data => $zbxArray} , { ascii => 1, pretty => 1 }) . "\n";
    exit;
}

my $ua = LWP::UserAgent->new(timeout=>$timeout, env_proxy=>1);
$ua->agent('zabbix-beegfs');

my $ref = getHTTPData($ua, "http://$hostname:$port/XML_StoragenodesOverview?timeSpanPerf=1");

my $avg = calcAvg($ref->{diskPerfWrite}->{value});
$output .= "- beegfs.diskPerfWrite[$mount] $avg\n";

$avg  = calcAvg($ref->{diskPerfRead}->{value});
$output .= "- beegfs.diskPerfRead[$mount] $avg\n";

$ref = getHTTPData($ua, "http://$hostname:$port/XML_MetanodesOverview?timeSpanPerf=1");

$avg = calcAvg($ref->{queuedRequests}->{value});
$output .= "- beegfs.queuedRequests[$mount] $avg\n";

$avg = calcAvg($ref->{workRequests}->{value});
$output .= "- beegfs.workRequests[$mount] $avg\n";

my $pid = open( FH, "| zabbix_sender -c /etc/zabbix_agentd.conf -i - >/dev/null 2>&1") or die "$!\n";
print FH $output;
close(FH);

print "1\n";

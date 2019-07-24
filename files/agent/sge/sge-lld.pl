#!/usr/bin/perl 
# Sensor for gathering SGE performance data for Zabbix

use strict;
use JSON;

# zabbix path
my $QSTAT = '/opt/sge/bin/lx-amd64/qstat';
my $GREP = '/bin/grep';

if (!$ENV{SGE_ROOT}) { 
   $ENV{SGE_ROOT}='/opt/sge'; 
}

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

my $cmd = $QSTAT . " -g c | " . $GREP . " -Ev \"(tecaj|vsmp-test)\"";
my $core_status = qx($cmd);
my @core_lines = split(/\n/, $core_status);
my $zbxArray = [];

foreach(@core_lines){
  my @core_fields = split(/ +/);
  if($core_fields[1] =~ /\d+/){
    my $ref = {'{#SGE_QUEUE}' => $core_fields[0]};
    push @{$zbxArray}, {%{$ref}};
  }
}

print to_json({data => $zbxArray} , { ascii => 1, pretty => 1 }) . "\n";


#!/usr/bin/perl 
# Sensor for gathering SGE performance data for Zabbix

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/SenderFileSGE";
my $zabbix_send_command="$zabbix_sender -c $zabbix_confd -i $send_file";
my $inputString = '';
my $hostname = qx("/bin/hostname");
my $QSTAT = '/opt/sge/bin/lx-amd64/qstat';
my $GREP = '/bin/grep';
my $SED = '/bin/sed';
my $AWK = '/bin/awk';
my $SORT = '/usr/bin/sort';
my $DOMAIN = ".isabella";

chomp($hostname);

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

# fetch status from qstat
my $cmd = $QSTAT . " -u '*'";
my $queue_status = qx($cmd);
my @lines = split(/\n/, $queue_status);
my $running = 0;
my $qwaiting = 0;
my $cpu_run = 0;
my $cpu_qw = 0;

foreach(@lines){
  my @fields = split(/ +/); 
  if($fields[5] =~ /^R?r$/gi){
    $running++;
    $cpu_run += $fields[9];
  }
  if($fields[5] =~ /qw/gi){
    $qwaiting++;
    $cpu_qw += $fields[8];
  }
}

# write data to variable
$inputString .= $hostname ." sge.running "  . $running             ."\n";
$inputString .= $hostname ." sge.qwaiting " . $qwaiting            ."\n";
$inputString .= $hostname ." sge.cpu_run "  . $cpu_run             ."\n";
$inputString .= $hostname ." sge.cpu_wait " . $cpu_qw              ."\n";
$inputString .= $hostname ." sge.cpu_total ". ($cpu_qw + $cpu_run) ."\n";

my $cmd = $QSTAT . " -g c | " . $GREP . " -Ev \"(tecaj|vsmp-test)\"";
my $core_status = qx($cmd);
my @core_lines = split(/\n/, $core_status);
my $core_tot = 0;
my $core_ava = 0;
my $core_aoACDS = 0;
my $core_cdsuE = 0;
my $core_used = 0;

foreach(@core_lines){
  my @core_fields = split(/ +/);
  if($core_fields[4] =~ /\d+/){
    $core_ava += $core_fields[4];
  }
  if($core_fields[5] =~ /\d+/){
    $core_tot += $core_fields[5];
  }
  if($core_fields[6] =~ /\d+/){
    $core_aoACDS += $core_fields[6];
  }
  if($core_fields[7] =~ /\d+/){
    $core_cdsuE += $core_fields[7];
  }
  if($core_fields[2] =~ /\d+/){
    $core_used += $core_fields[2];
  }
  if($core_fields[1] =~ /\d+/){
    $inputString .= $hostname ." sge.core_total[". $core_fields[0] ."] "  . $core_fields[5]            ."\n";
    $inputString .= $hostname ." sge.core_avail[". $core_fields[0] ."] " .  ($core_fields[5] - $core_fields[6] - $core_fields[7])          ."\n";
    $inputString .= $hostname ." sge.core_free[". $core_fields[0] ."] " . $core_fields[4]          ."\n";
  }
}

$inputString .= $hostname ." sge.core_total "  . $core_tot            ."\n";
$inputString .= $hostname ." sge.core_avail " .  ($core_tot - $core_aoACDS - $core_cdsuE)          ."\n";
$inputString .= $hostname ." sge.core_free " . $core_ava          ."\n";

my $cmd = $QSTAT . " -f | " . $GREP . " -Ev \"(tecaj|vsmp-test|--|qt|gpu)\" | " . $SED . " 's/[\\/|\\@|\\.]/\\ /g' | " . $AWK . " '{print \$3 \"" . $DOMAIN . "\",\$6,\$7,\$8,\$9 \".\" \$10,\$12}'";
my $core_status = qx($cmd);
my @core_lines = split(/\n/, $core_status);
my $core_used = 0;
my $core_avail = 0;
my $node_load = 0;

foreach(@core_lines){
  my @core_fields = split(/ +/);
    $inputString .= $core_fields[0] ." sge.core_res "  . $core_fields[1]            ."\n";
    $inputString .= $core_fields[0] ." sge.core_used " . $core_fields[2]            ."\n";
    $inputString .= $core_fields[0] ." sge.core_avail " . $core_fields[3]           ."\n";
    $inputString .= $core_fields[0] ." sge.node_load " . $core_fields[4]            ."\n";
   if($core_fields[5] eq ""){ 
    $inputString .= $core_fields[0] ." sge.node_state OK" . "\n";}
   else{
    $inputString .= $core_fields[0] ." sge.node_state " . $core_fields[5]           . "\n"}
    }

my $cmd = $QSTAT . " -f | " . $GREP . " gpu | " . $SED . " 's/[\\/|\\@]/\\ /g' | " . $SORT . " -k2,2 | " . $SED . " 's/gpu//g' | " . $AWK . " '{print substr(\$1,2,1),\$2,\$4,\$5,\$6,\$7,\$9}'";
my $core_status = qx($cmd);
my @core_lines = split(/\n/, $core_status);
my $core_used = 0;
my $core_avail = 0;
my $node_load = 0;

foreach(@core_lines){
  my @core_fields = split(/ +/);
    $inputString .= $core_fields[1] ." sge.core_res["  . $core_fields[0] . "] " . $core_fields[2]            ."\n";
    $inputString .= $core_fields[1] ." sge.core_used[" . $core_fields[0] . "] " . $core_fields[3]            ."\n";
    $inputString .= $core_fields[1] ." sge.core_avail[" . $core_fields[0] . "] " . $core_fields[4]           ."\n";
    $inputString .= $core_fields[1] ." sge.node_load[" . $core_fields[0] . "] " . $core_fields[5]            ."\n";
   if($core_fields[6] eq ""){
    $inputString .= $core_fields[1] ." sge.node_state OK" . "\n";}
   else{
    $inputString .= $core_fields[1] ." sge.node_state " . $core_field[6]           . "\n"}
    }

# write everything to file
open FH, ">", $send_file or die("Can not open file $send_file!");
print FH $inputString;
close(FH);

# finally, send the data
if ( qx($zabbix_send_command) =~ /Failed: 0/i ) {
   unlink ($send_file) or die("Can not remove file $send_file!");
   print("1\n");
   exit(0);
} else {
   unlink ($send_file) or die("Can not remove file $send_file!");
   print("0\n");
   exit(-1);
}

#EOF

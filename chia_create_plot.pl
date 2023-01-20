=b
The script help you install chia_blockchain.
https://github.com/Chia-Network/chia-blockchain.git
for downloading rpm, check the following: 
https://github.com/Chia-Network/chia-blockchain/releases
nohup some_command &> nohup2.out &
nohup some_command > /dev/null 2>&1 &
mkdir -v /mnt/madmax
mount -t tmpfs -o size=110G tmpfs /tmp/madmax
=cut

use warnings;
use strict;
use Cwd; #Find Current Path
use Parallel::ForkManager;
use Expect;

####chia pool, you can only choose one of the following
my $pool = 'xchpool';
my $poolkey = 'xch15g3g05pupm3qflyc7edru2x5efkfryvr25uk5s9ssfgdwumsfhas5ll07h';#
my $farmerKey = "a16d284cdc45bf967b6e44855a8d75679b9929a51e654ecc018ce495d50cf4f66952e4da9a3175d8d4d40c1f6e6067c4";

my $expectT = 5;# time peroid for expect
my $forkNo = 50;
my $pm = Parallel::ForkManager->new("$forkNo");
my $pmServer = Parallel::ForkManager->new("$forkNo");
my $datformat='+%Y%m%d%H%M';
my $getdate ="date"." $datformat ";

my $server_createplot = "yes";# type yes, if you want to install chia for server
my $serverPlotcmd = "chia plots create ";
my $node_createplot = "yes";
my $nodePlotcmd = "chia plots create";#"chia plots create ";

my @nodes = (1..3);#2..3;
#[tmp,-2temp,final,number for parallel,number for sequence,threads]
my @create_plot = (
    {server => [" /mnt/master/sda/"," /mnt/master/sda"," /mnt/master/sda",1,4,4]}#12G
	#{node01 => ["/free/","/free/","/free/",1,40,4]},
	#{node01 => ["/mnt/sdb/","/mnt/sdb/","/mnt/sdb/",1,40,4]},#8G,/free:888G,/sdb:931Gib
	#{node02 => ["/free/","/free/","/free/",1,40,4]},
	#{node02 => ["/mnt/sda/","/mnt/sda/","/mnt/sda/",1,6,4]},#16G,/free:878G,/sda:1.7T 
	#{node03 => ["/free/","/free/","/free/",1,40,4]},
	#{node03 => ["/mnt/sda/","/mnt/sda/","/mnt/sda/",1,40,4]} #16G,/free:878G,/sda:870G
	);
for my $cp (@create_plot){
	$pm->start and next;
	my @temp = keys %{$cp};# get keys (only one)
	print "\@temp:@temp\n";
	my $k = $temp[0];
	chomp $k;#key for the second dimensional array
	#print "\$k: $k\n";#keys node01...
	my @temp1 = @{$cp->{$k}};#array
	my $tempdir = $temp1[0];
	my $tempdir2 = $temp1[1];
	my $finaldir = $temp1[2];
	my $paraNo = $temp1[3];
	my $seqNo = $temp1[4];
	my $threadNo = $temp1[5];
    if($k eq "server" and $server_createplot eq "yes"){
			my $plotcmd = "nohup $serverPlotcmd \\
		-k 32 -b 3500 -t $tempdir -2 $tempdir2 -d $finaldir  -n $seqNo \\
		-f $farmerKey -c $poolkey 2>&1 > /dev/null &";
		#-p 94a2a566f4644c9f8c026c42df47ea6391a08524589f9b0bb3479f4f5aa97f9f2b8bf4a92dec4625c6a114d978569100"; 
		#exec("$plotcmd");
		#system("$plotcmd");
		my $pid = fork();
		if ($pid == 0) {exec("$plotcmd");}
	}
	elsif($node_createplot eq "yes" and $k ne "server"){
		my $plotcmd = "nohup $nodePlotcmd \\
		-k 32 -b 3500 -t $tempdir -2 $tempdir2 -d $finaldir -n $seqNo \\
		-f $farmerKey -c $poolkey 2>&1 >/dev/null &";
#-p 94a2a566f4644c9f8c026c42df47ea6391a08524589f9b0bb3479f4f5aa97f9f2b8bf4a92dec4625c6a114d978569100 & "; 
		my $cmd = "ssh $k ";
		#print ("$cmd '$plotcmd'");
		#system("$cmd '$plotcmd'");
		#exec("$cmd '$plotcmd'");
		my $pid = fork();
		if ($pid == 0) {exec("$cmd '$plotcmd'");}# if($pid == 0);
	}
	
  $pm-> finish;  
}#@create_plots loop
$pm->wait_all_children;
sleep(1);
system("ps aux|grep -v grep|grep 'ssh node'|grep jsp|awk '{print \$2}'|xargs kill");
sleep(1);
if($?) {print "$!\n";}
system("ps aux|grep -v grep|grep 'ssh node'");
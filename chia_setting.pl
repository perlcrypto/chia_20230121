=b
The script help you install chia_blockchain.
https://github.com/Chia-Network/chia-blockchain.git
for downloading rpm, check the following: 
https://github.com/Chia-Network/chia-blockchain/releases
=cut

use warnings;
use strict;
use Cwd; #Find Current Path
use Parallel::ForkManager;

my $forkNo = 50;
my $pm = Parallel::ForkManager->new("$forkNo");

my $server_install = "no";# type yes, if you want to install chia for server
my $node_install = "yes";
my @nodes = 1..3;

# server installation
if($server_install eq "yes"){
	system("/usr/lib/chia-blockchain/resources/app.asar.unpacked/daemon/chia init");
}

if($node_install eq "yes"){
	for (@nodes){
		chomp;
		$pm->start and next;
		my $nodeindex=sprintf("%02d",$_);
		my $nodename= "node"."$nodeindex";
		my $cmd = "ssh $nodename ";
		system("$cmd '/usr/lib/chia-blockchain/resources/app.asar.unpacked/daemon/chia init'"); 
		$pm->finish;
	}
	$pm->wait_all_children;
}

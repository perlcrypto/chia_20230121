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

my $server_install = "yes";# type yes, if you want to install chia for server
my $node_install = "no";
my @nodes = 1..3;
my $wgetORgit = "yes";#yes or no

# local folder
my $packageDir = "/home/jsp/packages";
if(!-e $packageDir){# if no /home/packages, make this folder	
	system("mkdir $packageDir");	
}

my $current_path = getcwd();# get the current path dir
my $URL = "https://github.com/Chia-Network/chia-blockchain/releases/download/1.2.3/chia-blockchain-1.2.3-1.x86_64.rpm";#url to download
my $Dir4download = "$packageDir/chia"; #the directory we download Mpich

if($wgetORgit eq "yes"){
	system("rm -rf $Dir4download");
	system("mkdir $Dir4download");
	chdir("$Dir4download");
	#system("git clone $URL");
	system("wget $URL");
	die "wget chia rpm failed!!!\n" if($?);
	chdir("$current_path");
}

# server installation
if($server_install eq "yes"){
	chdir("$Dir4download");
	system("dnf remove -y chia*");
	system("dnf localinstall -y ./chia*");
}

if($node_install eq "yes"){
	for (@nodes){
		chomp;
		$pm->start and next;
		my $nodeindex=sprintf("%02d",$_);
		my $nodename= "node"."$nodeindex";
		my $cmd = "ssh $nodename ";
		system("$cmd 'dnf remove -y chia*;'"); 
		system("$cmd 'cd $Dir4download;dnf localinstall -y ./chia*;'"); 
		system("$cmd '/usr/lib/chia-blockchain/resources/app.asar.unpacked/daemon/chia init'"); 
		system("rm -f  /usr/bin/chia");
		system("ln -s /usr/lib/chia-blockchain/resources/app.asar.unpacked/daemon/chia /usr/bin/chia");
        die "soft link failed!\n" if($?);
		$pm->finish;
	}
	$pm->wait_all_children;
}
system("rm -f  /usr/bin/chia");
system("ln -s /usr/lib/chia-blockchain/resources/app.asar.unpacked/daemon/chia /usr/bin/chia");
 die "soft link failed!\n" if($?);
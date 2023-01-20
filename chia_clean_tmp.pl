=b
kill all chia plot jobs and then clean all tmp files
=cut

use warnings;
use strict;
use Cwd; #Find Current Path
use Parallel::ForkManager;

#my $expectT = 5;# time peroid for expect
my $forkNo = 50;
my $pm = Parallel::ForkManager->new("$forkNo");
#my $pmServer = Parallel::ForkManager->new("$forkNo");
#kill chia plot jobs

for (1..3){
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "ssh $nodename ";
    print "\$nodename: $nodename\n";
    system(" $cmd \"ps aux|grep 'chia'|awk '{print \\\$2}'|xargs kill -9 \" ");#|awk \'{print \$2}\'|xargs kill'");
}

my @tmpFolder1 = `find /mnt/merger_nodedisk/ -type f -name ".tmp"`;#all tmp files
my @tmpFolder2 = `find /mnt/merger_master/ -type f -name ".tmp"`;#all tmp files
for (@tmpFolder1){chomp;print "$_\n";}
#for (@nodes){
#		chomp;
#		$pm->start and next;		
#
#		my $nodeindex=sprintf("%02d",$_);
#		my $nodename= "node"."$nodeindex";
#		my $cmd = "ssh $nodename ";
#	    for my $f (@{$tmp{$nodename}}){
#            print "$f\n";
#        my $pid = fork();
#		if ($pid == 0) {exec("$cmd '$node_cmd $f/*.tmp'");}
#	            }
#        $pm->finish;
#	    }
#	$pm->wait_all_children;
#}#if
#
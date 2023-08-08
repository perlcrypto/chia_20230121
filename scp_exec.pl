=b
Perl script to do the remote machine setting by using remote_setting.pl
or the file you assign
=cut

#!/usr/bin/perl
use strict;
use warnings;
use Parallel::ForkManager;
my @nodestest = 1..1;
my @nodes;
for (@nodestest){
    #$pm->start and next;
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "ssh $nodename ";
    print "\$nodename: $nodename\n";
    my $temp = `$cmd \"ps aux|grep -v grep|grep 'mv_plot.pl'\" `;#|awk \'{print \$2}\'|xargs kill'");
    print "\$temp:$temp\n";
    unless($temp){print "$_ in unless \$temp:$temp\n";push @nodes, $_;}
}
chomp @nodes;
#print "@nodes\n";

my $forkNo = 10;
my $pm = Parallel::ForkManager->new("$forkNo");

my $remote_perl = "/home/jsp/chia_blockchain/mv_plot.pl";
`mkdir -p /home/jsp/chia_remote_out`;
#`rm -p /home/jsp/chia_remote_out`;
for (@nodes){
    $pm->start and next;
    my $time= `date +%m%d%H%M%S`;
	chomp $time;
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "ssh $nodename ";
    print "\$nodename: $nodename\n";
    #system("scp  $remote_perl jsp\@$nodename:/home/jsp");
    #if ($?){print "BAD: scp  $remote_perl jsp\@$nodename:/home/jsp failed\n";};
    system("$cmd 'echo $nodename > /home/jsp/chia_remote_out/remote_setting-$nodename-$time.out'");
    sleep(1); 
    my $pid = fork();
    if( $pid == 0 ){
       exec("$cmd 'nohup perl $remote_perl 2>&1 >> /home/jsp/chia_remote_out/remote_setting-$nodename-$time.out &'"); 
     } 
   else {
   # die "could not fork a process: $!" unless defined $pid;
   # exec ( "/liwidata/dev/tmp/jmg/dev/library/test2.pl" ) or print STD
   # +ERR "couldn't exec test program: $!";
   # }
    #system("$cmd 'nohup perl $remote_perl 2>&1 >> /home/jsp/chia_remote_out/remote_setting-$nodename-$time.out &'"); 
    print "***$nodename done\n";
   }
    #system("$cmd 'cat home/jsp/remote_setting-$nodename-$time.out /home/jsp/chia_remote_out/'");
    #print "\n"; 
    $pm->finish;
}
$pm->wait_all_children;

=b
Perl script to do the remote machine setting by using remote_setting.pl
or the file you assign
=cut

#!/usr/bin/perl
use strict;
use warnings;
use Parallel::ForkManager;
# for server
print "Server check:\n";
system("ps aux|grep -v grep|grep chia");
#system("ps aux|grep chia|grep -v grep|awk '{print \$2}'|xargs kill -9");
my @nodes = (1..3);
#print "@nodes\n";

my $forkNo = 10;
my $pm = Parallel::ForkManager->new("$forkNo");

for (@nodes){
    #$pm->start and next;
    my $nodeindex=sprintf("%02d",$_);
    my $nodename= "node"."$nodeindex";
    my $cmd = "ssh $nodename ";
    print "\$nodename: $nodename\n";
    #system(" $cmd \"ps aux|grep chia|grep -v grep|awk '{print \\\$2}'|xargs kill -9 \" ");#|awk \'{print \$2}\'|xargs kill'");
    system(" $cmd \"ps aux|grep 'chia'|awk '{print \\\$2}'|xargs kill -9 \" ");#|awk \'{print \$2}\'|xargs kill'");
    #system(" $cmd \"ps aux|grep 'cp /free'|awk '{print \\\$2}'|xargs kill -9 \" ");#|awk \'{print \$2}\'|xargs kill'");
    #sleep(1);
    #system(" $cmd \"ps aux|grep -v grep|grep 'chia'\" ");#|awk \'{print \$2}\'|xargs kill'");
    #system(" $cmd \"ps aux|grep 'cp /mnt'\" ");#|awk \'{print \$2}\'|xargs kill'");
    #system(" $cmd \"ps aux|grep 'cp /free'\" ");#|awk \'{print \$2}\'|xargs kill'");
    #` $cmd "ps aux|grep mv_plot|awk \'{print \$2}\'"`;#|awk \'{print \$2}\'|xargs kill'");
    #system("$cmd 'df -h'");
    #system("$cmd 'cat nohup.out'");
    print "\n"; 
    #$pm->finish;
}
#$pm->wait_all_children;

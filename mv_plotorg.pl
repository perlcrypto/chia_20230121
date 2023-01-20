#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
use warnings;
use strict;
use Cwd; #Find Current Path
use Parallel::ForkManager;
my $forkNo = 50;
my $pm = Parallel::ForkManager->new("$forkNo");

#my $pid_file = "/home/jsp/perl_mv_plot.pid";
#my $pid;
#if(-f $pid_file) {#if file exists
#	$pid = `cat $pid_file`;
#	chomp $pid;
#	system("ps -p $pid > /dev/null 2>&1");
#	if(!$?){print "Job is still running\n";exit;}
#}
#
##if no pid file (no another job is ruuning)
#system("echo $$ > $pid_file");
#if($?){
#  print "Could not create PID file\n";
#  exit;
#}
#
#my @plot = `ls /mnt/merger_nodedisk|grep ".plot\$"`;
#for (@plot){
#for (0..0){
#	$pm->start and next;		
#	chomp;
	print "plotorg sleeping for 6 sec\n";
	#sleep(600);
	#system("mv /mnt/merger_nodedisk/$_ /mnt/merger_disk/");
#	$pm->finish;
#}
#$pm->wait_all_children;

#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

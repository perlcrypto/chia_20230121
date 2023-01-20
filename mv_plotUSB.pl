use warnings;
use strict;
use Cwd; #Find Current Path
use Parallel::ForkManager;
my $forkNo = 50;
my $pm = Parallel::ForkManager->new("$forkNo");

my $filepath = "/mnt/merger_disk";
my @plot = `ls $filepath|grep ".plot\$"`;
my $usbpath = "/mnt/temp";
for (@plot){
#	$pm->start and next;		
	chomp;
	my $filesize = `du $filepath/$_ |awk '{print \$1}'`;
	chomp $filesize;
	print "file szie: $filesize \n";
	my $avail = `df $usbpath|grep dev|awk '{print \$4}'`;
	chomp $avail;
	print "disk available space: $avail\n";
	if ($filesize <= $avail){
		system("mv $filepath/$_ $usbpath/");
	}
	else {exit;}
	#
#	$pm->finish;
}
#$pm->wait_all_children;

#* */3 * * * perl ~/mv_plot.pl

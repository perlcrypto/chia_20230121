#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
#0 */3 *
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $forkNo = 10;
my $pm = Parallel::ForkManager->new("$forkNo");

#path of each source dir
my @source = qw(
/mnt/nodes_nfs/node01/free
/mnt/nodes_nfs/node01/sdb
/mnt/nodes_nfs/node02/free
/mnt/nodes_nfs/node02/sda
/mnt/nodes_nfs/node03/free
/mnt/nodes_nfs/node03/sda
);

#path of each destination dir
my @destination = qw(
/mnt/sda
/mnt/sdb
/mnt/sdd
/mnt/sde
/mnt/sdf
/mnt/sdg
);

my %avail;
print "** available disk volume\n";
for my $d (@destination){
	my $temp = `df $d|grep dev|awk '{print \$4}'`;
    chomp $temp;
	$avail{$d} = $temp;
	#print "\$avail{$d}:$avail{$d}\n";
}
print "\n";

my @plotfiles;
my @plotsizes;
my @plotmv2path;
# find all plot files and their sizes		
for my $s (@source){
	chomp $s;
	my @plot = `ls $s|grep ".plot\$"`;

	#print "source $s\n";
    # print "\@plot:@plot\n";
     for my $p (@plot){
		chomp $p;
		my $filesize = `du $s/$p |awk '{print \$1}'`;
		chomp $filesize;
		
		if($filesize < 106000000) {
			system("rm -f $s/$p");
		}
		else{
			#print "$s/$p ->$filesize\n";
			push @plotfiles,"$s/$p";
			push @plotsizes,"$filesize"; 
		}
		
	 }
}# all source loop

for my $p (0..$#plotfiles){
	#print "$p: $plotfiles[$p] -> $plotsizes[$p]\n";
	for my $d (@destination){
		if($avail{$d} >= $plotsizes[$p]){
			push @plotmv2path, "$d";
			#print "$p: $plotfiles[$p]\n";
			#print "$avail{$d},$plotmv2path[-1]\n";
			#print "\n";
			$avail{$d} -= $plotsizes[$p];
			last;	
		}
		else{
		 next;	
		}
	}
}

for my $p (0..$#plotfiles){
#for my $p (1..3){
#	$pm->start and next;		
	chomp $p;
	#my $ps =`ps -aux|grep '$plotfiles[$p]'`;
	print "$plotfiles[$p]\n";
    #sleep(10);
    print "sleeping\n";
    my $ps =`lsof $plotfiles[$p]`;
    system("lsof $plotfiles[$p]");
	print "\$ps: $ps\n";
    #die;
    $ps =~ /($plotfiles[$p])/g;
	print "\$1: $1\n";

    #die "\n";
	if (`lsof $plotfiles[$p]`){
        print "using file: $plotfiles[$p]\n";
    #	system("cp $plotfiles[$p] $plotmv2path[$p]");
    #	if(! $?){system("rm -f $plotfiles[$p])")};
	}
	else{
		print "not using file:$plotfiles[$p]\n";
		#print "$plotfiles[$p]\n";	
	}
#	$pm->finish;
}
#$pm->wait_all_children;

#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

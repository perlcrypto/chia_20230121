=b
#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
move plot from nodes to server
=cut
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $forkNo = 10;
my $pm = Parallel::ForkManager->new("$forkNo");

my $hostname = `hostname`;
chomp $hostname;

#path of each source dir
my %source = (
    node01 => ["/free","/mnt/sdb"],
	node02 => ["/free","/mnt/sda"], 
	node03 => ["/free","/mnt/sda"]  
);

#path of each destination dir
my %destination = (
    node01 => ["/mnt/sdc","/mnt/sdd"],
	node02 => ["/mnt/sdc","/mnt/sdd"], 
	node03 => ["/mnt/sdc"]  
);

#my $hostname = "node01";
my @destination = @{$destination{$hostname}};
my @source = @{$source{$hostname}};
#
#print "@destination\n";
#print "@source\n";
#die;
my %avail;

print "** available disk volume\n";
for my $d (@destination){
	my $temp = `df $d|grep dev|awk '{print \$4}'`;
    chomp $temp;
	$avail{$d} = $temp;
	print "\$avail{$d}:$avail{$d}\n";
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
			print "$s/$p ->$filesize\n";
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
	#$pm->start and next;		
	chomp $p;
	unless(`lsof $plotfiles[$p]`){
    	system("cp $plotfiles[$p] $plotmv2path[$p]");
    	print "cp $plotfiles[$p] to $plotmv2path[$p] done!\n";
    	system("rm -f $plotfiles[$p]") unless($?);
       	print "rm $plotfiles[$p] done!\n";

	}
	#$pm->finish;
}
#$pm->wait_all_children;

#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

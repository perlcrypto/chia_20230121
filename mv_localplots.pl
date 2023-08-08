#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
#0 */3 *
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $forkNo = 10;
my $pm = Parallel::ForkManager->new("$forkNo");
my $hostname = `hostname`;
chomp $hostname;
#my @sourcefolders = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "free|sda|sdb"`;
my @sourcefolders = `find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"`;
#my @sourcefolders = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "free|sda|sdb"`;
chomp @sourcefolders;
@sourcefolders = (@sourcefolders);#,"/home/jsp/plots");
print "sourcefolders:@sourcefolders\n";

#path of each source dir
my %source = (
   master => [@sourcefolders]
);
my @destinationfolders1 = `find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"`;
#my @destinationfolders2 = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "free|sda|sdb"`;
#my @destinationfolders = (@destinationfolders1, @destinationfolders2);
my @destinationfolders = (@destinationfolders1);
chomp @destinationfolders;
print "destinationfolders: @destinationfolders\n";

#path of each destination dir
my %destination = (
   master => [@destinationfolders]
   # 
	#master => [
		#"/mnt/140.117.59.186/master/sdb","/mnt/140.117.59.186/nodes_nfs/node01",
	#,"/mnt/140.117.59.186/nodes_nfs/node02","/mnt/140.117.59.186/nodes_nfs/node03"
	#]
);

#my $hostname = "master";
my $grep_pattern = "140.117.59.186";
my @destination = @{$destination{$hostname}};
my @source = @{$source{$hostname}};
#
#print "@destination\n";
#print "@source\n";
#die;
my %avail;

print "** available disk volume\n";
for my $d (@destination){
	print "$d\n";
	my $temp = `df $d|grep $d|awk '{print \$4}'`;
    chomp $temp;
	#print "temp: $temp\n";
	$avail{$d} = $temp;
	die "you have not got the disk available capacity\n" unless($avail{$d});
	print "\$avail{$d}:$avail{$d}\n";
}
print "\n";

my @plotfiles;#absolute path of each plot
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
	for my $d (@destination){#find the destinaton for a plot
		if($avail{$d} >= $plotsizes[$p]){#enough space for this plot
			push @plotmv2path, ["$plotfiles[$p]","$d"];
			#print "$p: $plotfiles[$p]\n";
			#print "$avail{$d},$plotmv2path[-1]\n";
			#print "\n";
			$avail{$d} -= $plotsizes[$p];
			last;#find the proper dir for this plot	
		}
		else{
		 next;#go to next destination	
		}
	}
}
#$#plotfiles
for my $p (0..$#plotmv2path){
	print "**No. $p: doing rsync for $plotmv2path[$p][0] to $plotmv2path[$p][1]\n";
	$pm->start and next;		
	chomp $p;
	unless(`lsof $plotmv2path[$p][0] 2>/dev/null`){
    	system("rsync -av --progress --partial --append $plotmv2path[$p][0] $plotmv2path[$p][1]");
    	print "rsync $plotmv2path[$p][0] to $plotmv2path[$p][1] done!\n";
    	system("rm -f $plotmv2path[$p][0]") unless($?);
       	print "rm $plotmv2path[$p][0] done!\n";
	}
	$pm->finish;
}
$pm->wait_all_children;

#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

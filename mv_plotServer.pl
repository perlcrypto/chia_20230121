#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
#0 */3 *
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $forkNo = 1;
my $pm = Parallel::ForkManager->new("$forkNo");
my $hostname = `hostname`;
chomp $hostname;
#my @sourcefolders = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "sda"`;
my @sourcefolders = ("/mnt/master/sda/");
#my @sourcefolders = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "free|sda|sdb"`;
#print "@sourcefolders\n";
#die;
#
#my @sourcefolders = `find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"`;
#my @sourcefolders = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "free|sda|sdb"`;
chomp @sourcefolders;
@sourcefolders = (@sourcefolders);#,"/home/jsp/plots");
#print "sourcefolders:@sourcefolders\n";

#path of each source dir
my %source = (
   master => [@sourcefolders]
);
my @destinationfolders1 = `find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"`;
my @destinationfolders2 = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep -v "sda"`;
#my @destinationfolders2 = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep -v "free|sda|sdb"`;
#my @destinationfolders = (@destinationfolders1, @destinationfolders2);
#my @destinationfolders = (@destinationfolders1,@destinationfolders2);
my @destinationfolders = ("/home/jsp","/mnt/nodes_nfs/node03/sda","/mnt/nodes_nfs/node02/sda");
chomp @destinationfolders;
#print "destinationfolders: @destinationfolders\n";
#die;
#path of each destination dir
my %destination = (
   master => [@destinationfolders]
);

my @destination = @{$destination{$hostname}};
my @source = @{$source{$hostname}};
#
my @plots_source;#paths of all plot files
for (@source){
	chomp;
	my @plots = `find $_ -type f -name "*.plot"`;#find foldernames within which possess plot files
	chomp @plots; 
	@plots_source = (@plots_source,@plots)
}
#print "@destination\n";
#print "@source\n";
#die;
my %avail;

print "** available disk volume\n";
for my $d (@destination){
	print "$d\n";
	my $temp = `df $d|grep -v Filesystem |awk '{print \$4}'`;
	#my $temp1 = `df $d`;
    #chomp $temp1;
    chomp $temp;
	print "temp: $temp\n";
	#print "temp1: $temp1\n";
	$avail{$d} = $temp;
	#die "you have not got the disk available capacity\n" unless($avail{$d});
	print "\$avail{$d}:$avail{$d}\n";
}

my @plotfiles;#absolute path of each plot
my @plotsizes;
my @plotmv2path;
# find all plot files and their sizes		
for my $s (@plots_source){
	chomp $s;
	my $filesize = `du $s |awk '{print \$1}'`;
	chomp $filesize;
	print "$s with \$filesize: $filesize\n";

	if($filesize < 105000000) {#not a good plot file
		print "\$filesize: $filesize\n";
		print "!!!!!!removing plot file now\n";
		system("rm -f $s");
	}
	else{
		#print "$s ->$filesize\n";
		push @plotfiles,"$s";#all good files, which can be moved
		push @plotsizes,"$filesize";#the size of the corresponding plot file 
	}
}# all source loop

my $allNo = @plotfiles;#total plot files in the source bank 
print "\n!!! $allNo: Total plot files available in the source bank to be moved!!!\n";	
my @plot2move;
# get which destination folder we should cp plot file into
for my $p (0..$#plotfiles){
	#print "$p: $plotfiles[$p] -> $plotsizes[$p]\n";
	for my $d (@destination){#find the destinaton for a plot
		if($avail{$d} >= $plotsizes[$p]){#enough space for this plot
			push @plotmv2path,"$d";
			push @plot2move, "$plotfiles[$p]";
			$avail{$d} -= $plotsizes[$p];
			last;#find the proper dir for this plot	
		}
		else{
		 next;#go to next destination	
		}
	}
}

chomp @plot2move;
my $cpNo = @plot2move;#total plot files to be move 
print "!!! $cpNo: Total plot files can be moved!!!\n";	
#all set, and begin to do rsync

for my $p (0..$#plot2move){
	#$pm->start and next;		
	chomp $p;
	#unless(`lsof $plotfiles[$p] 2>/dev/null`){
	print "!Copying $plot2move[$p] to \n the folder, $plotmv2path[$p]!\n";
	my $basename = `basename $plot2move[$p]`;
	chomp $basename;
	#print "\$basename: $basename\n";			
	system("rsync -avz --progress --partial --append $plot2move[$p] $plotmv2path[$p]");
	#system("cp $plot2move[$p] $plotmv2path[$p]");
	print "rsync $plot2move[$p] to $plotmv2path[$p] done!\n";
	my $filesize = `du $plotmv2path[$p]/$basename |awk '{print \$1}'`;
	my $allfilesize = `du $plotmv2path[$p]/$basename`;
	chomp $filesize;
	chomp $allfilesize;
	print "output: $filesize,$allfilesize\n";
	print "copied plot: $plotmv2path[$p]/$basename\n";

	if($filesize > 106000000){#successfully copied!
		print "\n*copied file size: $filesize\n";
	     		print "*ready to rm $plot2move[$p]!\n";
		system("rm -f $plot2move[$p]");
	     		print "*rm $plot2move[$p] done!\n\n";				   
	}
	else{
		die "moving $plot2move[$p] failed\n";
	}
		#die "check the copy and rm situations!!!\n";
	#}
	#$pm->finish;
}#loop over all plot files
#$pm->wait_all_children;
#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

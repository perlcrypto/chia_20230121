#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
#0 */3 *
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $forkNo = 1;
my $pm = Parallel::ForkManager->new("$forkNo");
##remote servers for all destination folders 
my @remoteServer = ("140.117.60.161","140.117.59.182","140.117.59.186");

for my $rs (@remoteServer){#large loop to the last line
    chomp $rs;
    $rs =~ /140\.117\.\d+\.(\d+)/;#ip
	chomp $1;
    my $port = 20000 + $1;#port
    chomp $port;
    my $cmd = "ssh -p $port root\@$rs";
    my @remote_folder1  = `$cmd 'find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"'`;
    my @remote_folder2  = `$cmd 'find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"'`;
    chomp (@remote_folder1,@remote_folder2);
    my @destinationfolders = (@remote_folder1,@remote_folder2);
    #push @destinationfolders,(@remote_folder1,@remote_folder2);
    chomp @destinationfolders;
    #print "destinationfolders of $rs: @destinationfolders\n";

#rsync --rsh='ssh -p 20186' -av --progress --partial --append plot-k32-2021-09-21-12-22-f102cde3875b23f0f528b8a1a6e0a1f63c4ce4da53a2aa348a76f27d70919356.plot 140.117.59.186:/mnt/nodes_nfs/node01

#rsync -abvz --partial 
#path of each destination dir
    my %destination = (master => [@destinationfolders]);#machine name => foldernames
	#print "remote server $rs: @destinationfolders";
	#die;
	#my $grep_pattern = "140.117.59.186";
	my @destination = @{$destination{$hostname}};#destination folders
	my @source = @{$source{$hostname}};#all plot files
	my %avail;

	for my $d (@destination){
#		print "$d\n";
		my $temp = `$cmd "df $d|grep $d|awk '{print \\\$4}'"`;
	    chomp $temp;
		#print "temp: $temp\n";
		$avail{$d} = $temp;
		die "you have not got the disk available capacity\n" unless($avail{$d});
#		print "\$avail{$d}:$avail{$d}\n";		
	}
#	print "\n";
#die;
	my @plotfiles;
	my @plotsizes;
	my @plotmv2path;
# find all plot files and their sizes		
	for my $s (@source){#complete path of each plot file
		chomp $s;
		#my @plot = `ls $s|grep ".plot\$"`;
		#chomp @plot;
		##print "source $s\n";
	    #print "\@plot:@plot\n";
	    #for my $p (@plot){
			#chomp $p;
			my $filesize = `du $s |awk '{print \$1}'`;
			chomp $filesize;
			if($filesize < 105000000) {#not a good plot file
				print "\$filesize: $filesize\n";
				print "!!!!!!removing plot file now\n";
				#die;
				system("rm -f $s");
			}
			else{
				#print "$s ->$filesize\n";
				push @plotfiles,"$s";#all good files, which can be moved
				push @plotsizes,"$filesize";#the size of the corresponding plot file 
			}
		# }# loop over all plots in a source
	}# all source loop
	#die;
# get which destination folder we should cp plot file into
	for my $p (0..$#plotfiles){#over all plot files
		#print "$p: $plotfiles[$p] -> $plotsizes[$p]\n";
		for my $d (@destination){#finding destination folder with enough space
			if($avail{$d} >= $plotsizes[$p]){#enough space
				push @plotmv2path, "$d";
				$avail{$d} -= $plotsizes[$p];
				last;	
			}
			else{#not enough space
			 next;#try the next destination folder	
			}
		}
	}# loop over all plot files of all source folders
#all set, and begin to do rsync
	for my $p (0..$#plotfiles){
		#$pm->start and next;		
		chomp $p;
		#unless(`lsof $plotfiles[$p] 2>/dev/null`){
			print "!Copy $plotfiles[$p] into \n root\@$rs:$plotmv2path[$p]\n";
	    	system("rsync --rsh='ssh -p $port' -av --progress --partial --append $plotfiles[$p] root\@$rs:$plotmv2path[$p]");
	    	print "rsync $plotfiles[$p] to $rs:$plotmv2path[$p] done!\n";
		my $cmd = "ssh -p $port root\@$rs";
    	my $check  = `$cmd 'ls /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"'`;
   
my @check = `find /mnt/master -type f -name "*.plot"`;#find foldernames within which possess plot files
	    	
			system("rm -f $plotfiles[$p]") unless($?);
	       	print "rm $plotfiles[$p] done!\n";

		#}
		#$pm->finish;
	}
#$pm->wait_all_children;

}#loop over the remote_server 
#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

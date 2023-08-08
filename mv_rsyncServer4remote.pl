#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
#the following is for CLI test, be cautiioned to have the permission of remote folders
#rsync --rsh='ssh -p 20182' -av --progress --partial --append ./mv182.out jsp@140.117.59.182:/mnt/nodes_nfs/node01/free
#0 */3 *
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $forkNo = 1;
my $pm = Parallel::ForkManager->new("$forkNo");
my $hostname = `hostname`;#for server and nodes
chomp $hostname;
#my @sourcefolders1 = `find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"`;#find foldernames within which possess plot files
#my @sourcefolders2 = `find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"| egrep "free|sda|sdb"`;
my @plot1 = `find /mnt/master -type f -name "*.plot"`;#find foldernames within which possess plot files
my @plot2 = `find /home/jsp/plots -type f -name "*.plot"`;
my @plot3 = `find /mnt/nodes_nfs -type f -name "*.plot"`;

chomp (@plot1,@plot2,@plot3);
my @plots_source = (@plot1,@plot2,@plot3);
#my $counter = 0;
#for (@plots_source){
#	$counter++;
#	print "$counter: $_\n";
#	#$_ =~ m{.*/(.+\.plot)};
#	#unless($1){die "no plot file!\n"}
#	#else{print "$counter: $1\n"}
#}
#die;
#path of each plot file
my %source = (
   master => [@plots_source]
);

##remote servers for all destination folders 
my @remoteServer = ("140.117.59.182");#,"140.117.60.161","140.117.59.186");

for my $rs (@remoteServer){#large loop to the last line
    chomp $rs;
    $rs =~ /140\.117\.\d+\.(\d+)/;#ip
	chomp $1;
    my $port = 20000 + $1;#port
    chomp $port;
    my $cmd = "ssh -p $port jsp\@$rs";
    my @remote_folder1  = `$cmd 'find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"'`;
	#print "\$cmd: $cmd\n";
    my @remote_folder2  = `$cmd 'find /mnt/nodes_nfs -maxdepth 2 -mindepth 2 -type d -name "*"|grep -v node05'`;
    chomp (@remote_folder1,@remote_folder2);
	#print "\@remote_folder2: @remote_folder2\n";
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
		print "available capacity-> \$avail{$d}:$avail{$d}\n";		
	}
#	print "\n";

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
	my $allNo = @plotfiles;#total plot files in the source bank 
	print "\n!!! $allNo: Total plot files available in the source bank to be moved to $rs !!!\n";	
	my @plot2move;
# get which destination folder we should cp plot file into
	for my $p (0..$#plotfiles){#over all plot files
		#print "$p: $plotfiles[$p] -> $plotsizes[$p]\n";
		for my $d (@destination){#finding destination folder with enough space
			if($avail{$d} >= $plotsizes[$p]){#enough space
				push @plotmv2path, "$d";
				push @plot2move, "$plotfiles[$p]";
				$avail{$d} -= $plotsizes[$p];
				last;	
			}
			else{#not enough space
			 next;#try the next destination folder	
			}
		}
	}# loop over all plot files of all source folders
	chomp @plot2move;
	my $cpNo = @plot2move;#total plot files to be move 
	print "\n!!! $cpNo: Total plot files can be moved to $rs !!!\n";	

#all set, and begin to do rsync
	for my $p (0..$#plot2move){
		#$pm->start and next;		
		chomp $p;
		#unless(`lsof $plotfiles[$p] 2>/dev/null`){
	    	print "!Copying $plot2move[$p] to \n the folder in $rs:$plotmv2path[$p]!\n";
	    	my $basename = `basename $plot2move[$p]`;
			chomp $basename;
			#print "\$basename: $basename\n";			
			system("rsync --rsh='ssh -p $port' -av --progress --partial --append $plot2move[$p] jsp\@$rs:$plotmv2path[$p]");
	    	print "rsync $plot2move[$p] to \n $rs:$plotmv2path[$p] done!\n";
    		my $cmd = "ssh -p $port jsp\@$rs";	    	
			my $filesize = `$cmd "du $plotmv2path[$p]/$basename |awk '{print \\\$1}'"`;
			my $allfilesize = `$cmd "du $plotmv2path[$p]/$basename"`;
			chomp $filesize;
			chomp $allfilesize;
			print "output: $filesize,$allfilesize\n";
			print "remote plot: $plotmv2path[$p]/$basename\n";
			
			if($filesize > 106000000){#successfully copied!
				print "\n*remote file size: $filesize\n";
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

}#loop over the remote_server 
#system("rm -f $pid_file");
#* */3 * * * perl ~/mv_plot.pl

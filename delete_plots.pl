#my @bad_plots = `cat rsync.txt|awk '{print \$2}'`;
my @bad_plots = `cat rsync.txt`;
chomp @bad_plots;
#my @remoteServer = ("140.117.60.161");
#
#for my $rs (@remoteServer){#large loop to the last line
#    chomp $rs;
#    $rs =~ /140\.117\.\d+\.(\d+)/;
#    my $port = 20000 + $1;
#    chomp $port;
#    my $cmd = "ssh $rs -p $port ";
#    #my @remote_folder1  = `$cmd 'find /mnt/master -maxdepth 1 -mindepth 1 -type d -name "*"'`;
#    my @remote_plots  = `$cmd 'find /mnt/nodes_nfs -maxdepth 2 -mindepth 2  -name "*"'`;
#    chomp (@remote_plots);
#    for my $p (@remote_plots){
#		print "$p\n";	
#            #chomp $p;
#			#my $filesize = `du $s/$p |awk '{print \$1}'`;
#			#chomp $filesize;
#			#if($filesize < 106000000) {
#			#	system("rm -f $s/$p");
#			#}
#    }	
#
#    
#}

for (@bad_plots){
    chomp;
    print "removing /mnt/merger_master/$_\n";
    `ls /mnt/merger_master/$_`;
    unless($?){
        print "**exist $_\n";
        `rm -rf /mnt/merger_master/$_`;
        }

    `ls /mnt/merger_nodedisk/$_`;
    unless($?){
        print "**exist $_\n";
        `rm -rf /mnt/merger_nodedisk/$_`;
        }   
    #system("rm -rf /mnt/merger_master/$_");
    #print "removing $_ done\n";
    
    }
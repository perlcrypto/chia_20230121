my $port = "20161";
my $rs = "140.117.60.161";

my $cmd = "ssh -p $port root\@$rs";
my $plot = "/mnt/master/sda/plot-k32-2021-11-02-16-42-76c0d64a46482b5d5abfa17447c2112d5b083789135b7049be88a4e591fe5fc0.plot";
my $remote = "/mnt/nodes_nfs/node04/free";
my $basename = `basename $plot`;
chomp $basename;	    	
my $filesize = `$cmd "du $remote/$basename |awk '{print \\\$1}'"`;
chomp $filesize;
print "\$filesize: $filesize\n";
if($filesize > 105000000){print "test number ok\n";}
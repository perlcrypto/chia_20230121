#https://blog.gtwang.org/linux/prevent-shell-script-duplicate-executions/
#0 */3 *
use warnings;
use strict;
use Cwd; #Find Current Path
#use MCE::Shared;
use Parallel::ForkManager;
my $threads = `lscpu|grep "^CPU(s):" | sed 's/^CPU(s): *//g'`;
chomp $threads;
#print "Total threads of this machine is $threads\n";

my $forkNo = $threads;
my $pm = Parallel::ForkManager->new("$forkNo");
my @plot_dir = ("/mnt/merger_master","/mnt/merger_nodedisk");
my @plotname;
my @nocontract;
for (@plot_dir){
    chomp;
    my @temp = <$_/*.plot>;
    for my $p (sort @temp){
        my @check = `chia plots check -n 1 -g $p 2>&1|grep "Pool public key:"|awk '{print \$NF}'`;
        #system("chia plots check -n 1 -g $p");# 2>&1|grep "Pool public key:"|awk '{print \$NF}'`;
        chomp @check;
        #print "\$check[0]: $check[0]\n";
        #print "\$p: $p\n";

        unless($check[0] =~ /None/) {push @nocontract,$p ;}
        else{next;}#"Pool public key:"
       
    }
    #print "@temp\n";
    #die;
}
for (@nocontract){
    chomp;
    print "$_\n";
}

#$#plotfiles
for my $p (@nocontract){
	$pm->start and next;		
	chomp $p;
    system("rm -f $p");
    print "rm $p done!\n";
	$pm->finish;
}
$pm->wait_all_children;
print "All Done!\n";

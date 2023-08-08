 #plot_directories:
use strict;
use warnings;
use Cwd;

my @temp = `find /mnt -type f -name "*.plot"`;
map { s/^\s+|\s+$//g; } @temp;
my %hash;

for (@temp){
	my $temp = `dirname $_`;
	chomp $temp;
	$hash{$temp} = 1;	
}
`touch plotdir.txt`; 
for (sort keys %hash){
    print "- $_\n";
    `echo \"- $_\" >> plotdir.txt`;
}

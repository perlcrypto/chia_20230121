my @all_plots = `find /mnt -type f -name "*.plot"`;
chomp @all_plots;
my %all_dirs;
for (@all_plots){
    my $temp = `dirname $_`;
    chomp $temp;
    $all_dirs{$temp} = 1;
}

for (sort keys %all_dirs){
    chomp;
    print "- $_\n";
}
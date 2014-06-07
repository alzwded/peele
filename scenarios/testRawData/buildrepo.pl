#!/usr/bin/perl -w

use strict;
use Data::Dumper;

my @indirs = map { $_ =~ s/^(.*)\/$/$1/; $_ } sort @ARGV;

system("rm -rf repo") and die;
system("mkdir repo") and die;
system("git init repo") and die;

foreach my $dir(@indirs) {
    my @files = sort split /\n/, `find $dir -type f`;
    my @currentFiles = sort grep { $_ !~ m/^\..*/ } map { (substr($_, 5)) } split /\n/, `find repo -type f`;
#print Dumper (grep { $_ !~ m/^\..*$/ } map { (substr($_, 5)) } split /\n/, `find repo -type f`);

    print "-"x 72 . "\n";
    print Dumper @currentFiles;
    my %covered = map { $_ => 1 } @currentFiles;
    print Dumper %covered;
    print "-"x 72 . "\n";

    foreach my $file (@files) {
        print "$dir||$file\n";
        my $key = substr $file, (length($dir) + 1);
        print "  $key\n";
        if($covered{$key}) {
            print "  $key deleted\n";
            delete $covered{$key};
        }
        print "  tar cv -C $dir $key | tar xv -C repo --ignore-command-error-m \n";
        system("tar cv -C $dir $key | tar xv -C repo --ignore-command-error -m ") and die;
        system("git --work-tree=repo --git-dir=repo/.git add $key") and die;
    }

    print Dumper %covered;

    foreach(keys %covered) {
        print "removing $_\n";
        system("git --work-tree=repo --git-dir=repo/.git rm $_") and die;
    }

    system("git --work-tree=repo --git-dir=repo/.git commit -m '$dir'") and exit;
}

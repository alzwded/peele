#!/usr/bin/perl -w

use strict;

use Plugins::PRScanner;
use Data::Dumper;

my @gb = glob "/mnt/Data/Dropbox/thesis/app/repoBuilder/PRs/ComponentA/*.json";
print Dumper \@gb;
my $in = {
    type => 'array',
    value => \@gb,
};
print Dumper $in;

my $f = PRScanner->new({});
my $r = $f->apply($in);
print Dumper $r;

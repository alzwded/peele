#!/usr/bin/perl -w

use Plugins::HxxScanner;
use Data::Dumper;

use warnings;
use strict;

# NOTE: use http://github.com/alzwded/etc/tree/master/shellOneLiners/buildrepo.pl
#       to build a maintainable test repo without much hassle

my @files = glob "/mnt/Data/Dropbox/thesis/app/repoBuilder/repo/ComponentA/*.hxx";

my $f = HxxScanner->new({});
my $r = $f->apply({
    type => 'array',
    value => \@files,
});

print Dumper $r;

@files = glob "/mnt/Data/Dropbox/thesis/app/repoBuilder/repo/ComponentB/*.hxx";
$r = $f->apply({
    type => 'array',
    value => \@files,
});

print Dumper $r;

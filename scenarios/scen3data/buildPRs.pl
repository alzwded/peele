#!/usr/bin/perl -w

use strict;

my $revision = shift @ARGV;
my @times = @ARGV;

die 'no PRs this revision?' unless scalar @times > 0;

my @severities = ("general", "critical", "blocking", "cosmetic", "general", "critical");

my $idx = 0;
foreach my $time (@times) {
    open A, ">PR_${revision}_$idx.json";
    my $r = int rand scalar @severities;
    print A <<EOT;
{
    "revision":"$revision",
    "severity":"$severities[$r]",
    "spent":"$time",
    "date":"1/1/1970"
}
EOT
    close A;
    ++$idx;
}

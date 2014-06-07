#!/usr/bin/perl -w

use Plugins::Select;

my $val1 = {
    type => 'wave',
    value => {
        plot1 => [1, 2, 3],
        plot2 => [0, 0, 0],
    },
};

my $val2 = {
    type => 'array',
    value => [4, 5, 6],
};

my $val3 = {
    type => 'field',
    value => 42,
};

my $val4 = {
    type => 'wave',
    value => {
        plot3 => [0, 0, 0],
        plot4 => [7, 8, 9],
    },
};

my $f = Select->new({
    '@waveNames' => [ 'plot1', 'plot2', 'plot3', 'plot4' ],
});
use Data::Dumper;
print "=" x 72 . "\n";
print "P1: ";
my $r1 = $f->apply($val1);
print Dumper $r1;

print "=" x 72 . "\n";
print "P2: ";
my $l1 = $r1->{value}->{plugin}->new($r1->{value}->{config});
my $r2 = $l1->apply($val2);
print Dumper $r2;

print "=" x 72 . "\n";
print "P3: ";
my $l2 = $r2->{value}->{plugin}->new($r2->{value}->{config});
my $r3 = $l2->apply($val3);
print Dumper $r3;

print "=" x 72 . "\n";
print "P4: ";
my $l3 = $r3->{value}->{plugin}->new($r3->{value}->{config});
my $r4 = $l3->apply($val4);
print Dumper $r4;

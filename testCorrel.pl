#!/usr/bin/perl -w

use Plugins::XCorrel;
use Plugins::MinMax;

my @a;
my @b;

@a = (1, 2, 3, 2, 3, 4, 5, 4, 5, 6);
@b = (1, 1.5, 1.5, 1.3, 1.5, 1.7, 1.8, 1.7, 1.8, 2);
doit(\@a, \@b);

@a = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
@b = reverse @a;
doit(\@a, \@b);

@b = @a;
doit(\@a, \@b);

@a = (1, 5, 10, 5, 1, 5, 10, 5, 1);
@b = (5, 10, 5, 1, 5, 10, 5, 1, 5);
doit(\@a, \@b);

@a = (0, 0, 0, 0, 1, 1, 1, 0, 0, 0);
@b = (0, 0, 0, 0, 1, 0.5, 0.1, 0, 0, 0);
doit(\@a, \@b);

@a = (1, 4, 7, 9, 10, 9, 7, 4, 1, 1);
@b = (7, 8, 9, 5, 6, 1, 3, 2, 1, 1);
doit(\@a, \@b);

@a = (1, 4, 7, 9, 10, 9, 7, 4, 1, 1);
@b = (10, 10, 10, 1, 1, 1, 10, 10, 10, 1);
doit(\@a, \@b);

@a = (1, 0, 0, 0, 0, 1, 0, 0, 0, 0);
@b = (0, 0, 1, 0, 0, 0, 0, 1, 0, 0);
doit(\@a, \@b);

@a = (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0);
@b = (0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0);
doit(\@a, \@b);

sub doit {
    my ($a, $b) = @_;

    my $f = XCorrel->new({});
    my $y = $f->apply({
        type => 'wave',
        value => {
            a => $a,
            b => $b,
        }
    });

    use Data::Dumper;
    print Dumper $y;

    my $f = MinMax->new({which => 'correl', what => 'min'});
    print Dumper $f->apply($y);

    my $f = MinMax->new({which => 'correl', what => 'max'});
    print Dumper $f->apply($y);
}

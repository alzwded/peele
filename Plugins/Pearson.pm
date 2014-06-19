package Pearson;

use strict;
use warnings;

sub new {
    my ($class, $cfg) = @_;
    my $self = {};
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'wave') {
        my $means = {};
        my $sigmas = {};
        my $normalized = {};
        my $n = 10.0**23;
        my $cn = undef;
        foreach (keys %{ $x->{value} }) {
            my $key = $_;
            ($means->{$key}, $sigmas->{$key}, $cn) = compute_mean($x->{value}->{$key});
            if($cn < $n) { $n = $cn }
        }
        unless(defined $cn) {
            print "Pearson: NO INPUT\n";
            return {
                type => 'wave',
                value => {},
            };
        }
        my $corr = compute_correl($x->{value}, $means, $sigmas, $n);

        return {
            type => 'field',
            value => $corr,
        };
    } else {
        return {
            type => 'wave',
            value => {},
        }
    }
}

sub default_parameters {
    return {};
}

sub compute_mean {
    my $sum = 0;
    my $s = 0;
    my $nThings = 0;
    
    my @numbers = @{ $_[0] };

    $nThings = @numbers;
    for(my $i = 0; $i < $nThings; ++$i) {
        $sum += $numbers[$i];
    }
    $sum /= $nThings;

    for(my $i = 0; $i < $nThings; ++$i) {
        $s += ($numbers[$i] - $sum) ** 2;
    }
    $s /= $nThings;

    return ($sum, sqrt($s), $nThings);
}

sub compute_correl {
    my ($waves, $means, $sigmas, $n) = @_;
    my @thing = ();

    my $sum = 0;
    for(my $i = 0; $i < $n; ++$i) {
        my $prod = 1;
        foreach (keys %{ $waves }) {
            my $key = $_;
            $prod *= @{ $waves->{$key} }[$i] - $means->{$key};
        }
        $sum += $prod;
    }
    $sum /= $n;
    
    my $denom = 1;
    foreach (keys %{ $waves }) {
        $denom *= $sigmas->{$_};
    }

    return $sum / $denom;
}

1;

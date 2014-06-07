package XCorrel;

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
        my $n = 'inf';
        my $cn = undef;
        foreach (keys %{ $x->{value} }) {
            my $key = $_;
            ($means->{$key}, $sigmas->{$key}, $cn) = compute_mean($x->{value}->{$key});
            if($cn < $n) { $n = $cn }
        }
        my $corr = compute_correl($x->{value}, $means, $sigmas, $n); # argh, already normalized

        foreach (keys %{ $x->{value} }) {
            $x->{value}->{$_} = normalize($x->{value}->{$_}, $means->{$_}, $sigmas->{$_});
        }
        $x->{value}->{correl} = $corr;

        return $x;
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

sub normalize {
    my $mean = $_[1];
    my $sigma = $_[2];
    my @numbers = map { ($_ - $mean) / $sigma } @{ $_[0] };

    return \@numbers;
}

sub compute_correl {
    my ($waves, $means, $sigmas, $n) = @_;

    my @thing = ();
    for(my $i = -$n + 1; $i < $n; ++$i) {
        my $sum = 0;
        for(my $t = 0; $t < $n; ++$t) {
            my $n = 0;
            my $prod = 1;
            foreach (keys %{ $waves }) {
                my $key = $_;
                my $j = $n * $i + $t;
                if($j >= @{ $waves->{$key} }
                    or $j < 0)
                {
                    $prod = 0;
                } else {
                    $prod *= @{ $waves->{$key} }[$j] - $means->{$key}
                }
                ++$n;
            }
            $sum += $prod;
        }

        my $denom = 1;
        foreach (keys %{ $sigmas }) {
            $denom *= $sigmas->{$_};
        }
        push @thing, $sum / ($n * $denom);
    }
    
    # upsample the input tzignalz
    foreach (keys %{ $waves }) {
        my $key = $_;
        my @new = ();
        for(my $i = 0; $i < @{ $waves->{$key} } - 1; ++$i) {
            push @new, @{ $waves->{$key} }[$i];
            push @new, (@{ $waves->{$key} }[$i] + @{ $waves->{$key} }[$i + 1]) / 2;
        }
        push @new, @{ $waves->{$key} }[scalar(@{ $waves->{$key} }) - 1];

        $waves->{$key} = \@new;
    }

    return \@thing;
}

1;

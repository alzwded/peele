package PRScanner;

use strict;
use warnings;

use JSON::PP;

sub new {
    my ($class, $cfg) = @_;
    my $self = {};
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'array') {
        my @files = @{ $x->{value} };
        unless(scalar @files > 0) {
            return {
                type => 'array',
                value => [],
            };
        }

        foreach (@files) {
            $self->parse_pr($_);
        }

        my $data = $self->stats();

        return {
            type => 'wave',
            value => $data,
        }
    } elsif($x->{type} eq 'field') {
        my $ary = {
            type => 'array',
            value => [$x],
        };
        return $self->apply($ary);
    } else {
        return {
            type => 'array',
            value => [],
        }
    }
}

sub default_parameters {
    return {};
}

sub parse_pr {
    my ($self, $fileName) = @_;
        
    my $file = "";
    open A, "<$fileName" or return;
    while(<A>) {
        $file .= $_;
    }
    close A;

    my $pr = decode_json($file);

    unless(ref $pr eq 'HASH'
        and defined $pr->{revision}
        and defined $pr->{spent})
    {
        print "PRScanner: $file is in a weird format\n";
        return;
    }

    my @a = (defined $self->{$pr->{revision}}) ? @{ $self->{$pr->{revision}} } : ();
    push @a, $pr->{spent};
    $self->{$pr->{revision}} = \@a;
}

sub stats {
    my ($self) = @_;
    my $r = {
        timeavg => [],
        num => [],
        timetot => [],
    };

    foreach (sort keys %{ $self }) {
        my $key = $_;

        my $num = scalar @{ $self->{$key} };
        push @{ $r->{num} }, $num;

        my $meanH = 0;
        foreach (@{ $self->{$key} }) {
            $meanH += $_;
        }
        push @{ $r->{timetot} }, $meanH;

        $meanH /= $num;
        push @{ $r->{timeavg} }, $meanH;
    }

    $r
}

1;

package MinMax;

use strict;
use warnings;

sub new {
    my ($class, $cfg) = @_;
    my $self;
    if(ref $cfg ne 'HASH'
        or !defined $cfg->{'$which'}
        or !defined $cfg->{'$what'})
    {
        print "MinMax: invalid configuration\n";
        $self = {};
    } else {
        $self = $cfg;
    }
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'wave') {
        my $comparator = $self->get_comparator();
        my @list = sort { &$comparator($a, $b) } @{ $x->{value}->{$self->{which}} };
        return $list[0];
    } elsif($x->{type} eq 'array') {
        my $comparator = $self->get_comparator();
        my @list = sort { &$comparator($a, $b) } @{ $x->{value} };
        return $list[0];
    } else {
        return {
            type => 'field',
            value => '0',
        };
    }
}

sub default_parameters {
    return {
        '$which' => 'plot',
        '$what' => 'min',
    };
}

sub get_comparator {
    my $self = shift;
    if($self->{'$what'} eq 'min') {
        return sub { $_[0] <=> $_[1] };
    } elsif($self->{'$what'} eq 'max') {
        return sub { $_[1] <=> $_[0] };
    }
}

1;

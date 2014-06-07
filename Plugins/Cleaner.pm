package Cleaner;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

sub apply {
    return undef;
}

sub default_parameters {
    return {};
}

1;

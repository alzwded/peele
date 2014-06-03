package SQLiteDB;

use strict;
use warnings;

sub default_parameters {
    return (
        '$db' => "./database.sqlite3",
    );
}

sub open {
    my ($config) = @_;

    # open connection with config in config
    # open transaction
    ...
}

sub close {
    # commit transaction
    # close connection
    ...
}

sub abort {
    # abort transaction
    # close connection
    ...
}

sub get {
    my ($varName) = @_;

    ...

    return (
        type => ...,
        value => ...,
    );
}

sub set {
    my ($varName, %value) = @_;

    my $name = $value{name};
    my $type = $value{type};

    if($type eq 'field') {
    } elsif($type eq 'array') {
    } elsif($type eq 'wave') {
    } elsif($type eq 'lambda') {
    } else {
        die "invalid type: $type";
    }
}

package dbThing;

sub open { print "dbThing opened\n"; }
sub close {}
sub abort {}
sub get {}
sub set {}
sub default_parameters {
    return (
        '$a' => 42,
        '@b' => [1, 2, 3],
    );
}

1;

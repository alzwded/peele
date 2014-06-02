package dbThing;

sub configure {}
sub open { print "dbThing opened\n"; }
sub close {}
sub default_parameters {
    return {
        '$a' => 42,
        '@b' => [1, 2, 3],
    };
}

1;

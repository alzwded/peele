package Core::ExpressionEngine;

use Core::DBEngine;

sub run_all {
    my ($running, $update, $chains, $db) = @_;

    my $slice = 100 / (scalar @{ $chains });
    my $val = 0;

    my $idx = 0;
    foreach (@{ $chains }) {
        run_chain($running, sub {
                my ($currentVal) = @_;
                $val = $idx * $slice + $slice * $currentVal/ 100;
                &{ $update }(int($val));
            }, $_, $db)
            or return;

        &{ $update }(int($idx * $slice)); # account for any round-off errors (i.e. values smaller than 1)
        ++$idx;

        last if !$$running;
    }
}

sub run_chain {
    my ($running, $update, $chain, $db) = @_;

    foreach (@{ $chain }) {
        my ($y, $f, $cfg, $x) = @{ $_ };

        if($x =~ m/^`(.*)/) {
            my $pattern = quotemeta $1;
            my @files = glob "$1";
            $x = {
                type => "array",
                value => \@files,
            };
        } elsif($x =~ m/^%(.*)/) {
            my $varName = $1;
            $x = $db->get($varName);
            if(!defined $x) {
                print "could not retrieve $varName from database!\n";
                return undef;
            }
            if($x->{type} eq 'lambda') {
                $x = $x->{value}->{return};
            }
        } else {
            $x = {
                type => "field",
                value => $x,
            };
        }

        if($f =~ m/^%(.*)/) {
            my $varName = $1;
            my $dbVar = $db->get($varName);
            if(!defined $dbVar) {
                print "could not retrieve $varName from database!\n";
                return undef;
            }
            if($dbVar->{type} ne 'lambda') {
                print "$varName in 'f' position is not a lambda\n";
                return undef;
            }
            $f = $dbVar->{value}->{plugin};
            $cfg = $dbVar->{value}->{config};
        }

        if($y !~ m/^%(.*)/) {
            print "'y' must be a variable! (starts with a % sign)\n";
            return undef;
        } else {
            $y = $1;
        }

        my $realFunc = $f->new($cfg);
        my $result = $f->apply($x);

        unless(
            ref $result eq 'HASH'
            and defined $result->{type}
            and $result->{type} =~ m/(field\|array\|wave\|lambda)/
            and defined $result->{value})
        {
            print "$f returned invalid result\n";
            return undef;
        }

        $db->set($y, $result);
    }

    return 1;
}

1;

package Core::ExpressionEngine;

use Core::DBEngine;

use warnings;
use strict;

sub run_all {
    my ($running, $update, $chains, $dbCfg) = @_;
    my $db = Core::DBEngine->new($dbCfg);

    my $slice = 100 / (scalar @{ $chains });
    my $val = 0;

    my $idx = 0;
    foreach (@{ $chains }) {
        run_chain($running, sub {
                my ($currentVal) = @_;
                $val = $idx * $slice + $slice * $currentVal/ 100;
                &{ $update }(int($val));
            }, $_, $db)
            or last;

        ++$idx;
        &{ $update }(int($idx * $slice)); # account for any round-off errors (i.e. values smaller than 1)

        last if !$$running;
    }
}

sub run_chain {
    my ($running, $update, $chain, $db) = @_;

    my $idx = 0;
    my $total = scalar @{ $chain };
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

        print "Preparing to evaluate:\n";
        print "Y = ";
        use Data::Dumper;
        print Dumper $y;
        print "F = ";
        print Dumper $f;
        print "CFG = ";
        print Dumper $cfg;
        print "X = ";
        print Dumper $x;

        my $realFunc;
        my $result;

        eval {
            $realFunc = $f->new($cfg);
            $result = $realFunc->apply($x);
        };
        if($@) {
            print "drastic error in plugin $f ($@), aborting\n";
            return undef;
        }

        unless(
            !defined $result
            or ref $result eq 'HASH'
            and defined $result->{type}
            and $result->{type} =~ m/(field|array|wave|lambda)/
            and defined $result->{value})
        {
            print "$f returned invalid result\n";
            return undef;
        }

        $db->set($y, $result);

        &{ $update }(int(++$idx / $total * 100));
    }

    return 1;
}

1;

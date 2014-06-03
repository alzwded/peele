package SQLiteDB;

use strict;
use warnings;

use DBI;
use DBD::SQLite;
use JSON::PP;

my $dbh = undef;
my %st = (
    getAll => "SELECT (id) FROM main ;",
    getType => "SELECT (stype) FROM main WHERE id = ? ;"
    getField => "SELECT (value) FROM fields WHERE id = ? ;",
    getArray => "SELECT (value) FROM arrays WHERE id = ? ORDER BY idx ASC ;"
    getWave => "SELECT (plotname, value) FROM waves WHERE id = ? ORDER BY plotname, idx ;"
    getLambdaRT => "SELECT (rettype) FROM lambdas WHERE id = ? ;",
    getLambdaRef => "SELECT (value) FROM lambdas WHERE id = ? ;",
    zap => "DELETE FROM main WHERE id = ? ;",
    insMain => "INSERT INTO main (id, stype) VALUES (?, ?) ;",
    insField => "INSERT INTO fields (id, value) VALUES (?, ?) ;",
    insArrayElement => "INSERT INTO arrays (id, idx, value) VALUES (?, ?, ?) ;",
    insWaveElement => "INSERT INTO waves (id, plotname, idx, value) VALUES (?, ?, ?, ?) ;",
    insLambdaRef => "INSERT INTO lambdas (id, rettype, value) VALUES (?, ?, ?) ;",
);
my %sth = ();

sub default_parameters {
    return (
        '$dbname' => "./database.sqlite3",
    );
}

sub open {
    my ($config) = @_;

    # open connection with config in config
    # open transaction

    $dbh = DBI->connect("dbi:SQLite:dbname=".$config->{dbname}, '', '',
        { RaiseError => 0, Autocommit => 0 })
        or return;

    foreach (keys %st) {
        my $key = $_;
        $sth{$key} = $dbh->prepare($st{$key});
    }
    $dbh->begin_work();
}

sub cleanup {
    return unless defined $dbh;
    foreach (keys %sth) {
        my $key = $_;
        $sth{$key}->finish();
        delete $sth{$key};
    }
    $dbh->disconnect();
    $dbh = undef;
}

sub close {
    # commit transaction
    $dbh->commit();

    # close connection
    cleanup();
}

sub abort {
    # abort transaction
    # close connection
    cleanup();
}

sub get_all {
    $sth{getAll}->execute();
    return @{ $sth{getAll}->fetchall_arrayref([0]) };
}

sub get {
    my ($varName) = @_;

    $sth{getType}->execute($varName);
    my $type = $sth{getType}->fetchrow()[0];
    
    return get_helper($varName, $type);
}

sub get_helper {
    my ($varName, $type) = @_;

    if($type eq 'field') {
        $sth{getField}->execute($varName);
        my $value = $sth{getField}->fetchrow[0];
        return (
            type => 'field',
            value => $value,
        );
    } elsif($type eq 'array') {
        $sth{getArray}->execute($varName);
        my @value = @{ $sth{getArray}->fetchall_arrayref([0]) };
        return (
            type => 'array',
            value => \@value,
        );
    } elsif($type eq 'wave') {
        $sth{getWave}->execute($varName);
        my %ret = ();
        while(my $row = $sth{getWave}->fetchrow_hashref()) {
            my ($plotName, $value) = ($row->{plotname}, $row->{value});
            if(!defined($ret{plotName})) {
                $ret{plotName} = [];
            }
            push $ret{plotName}, $value;
        }
        return (
            type => 'wave',
            value => \%ret,
        );
    } elsif($type eq 'lambda') {
        $sth{getLambdaRT}->execute($varName);
        my $returnType = $sth{getLambdaRT}->fetchrow()[0];

        $sth{getLambdaRef}->execute($varName);
        my $payload = decode_json($sth{getLambdaRef}->fetchrow()[0]);

        my $data = get_helper($varName, $returnType);
        $payload->{return} = $data;

        return (
            type => 'lambda',
            value => $payload,
        );
    } else {
        die "invalid type: $type";
    }

    return (
        type => $type,
        value => ...,
    );
}

sub set {
    my ($varName, %value) = @_;

    my $name = $varName;
    my $type = $value{type};
    my $data = $value{value};

    $sth{zap}->execute(($name));
    $sth{insMain}->execute(($name, $type));

    set_helper($name, $type, $data);
}

sub set_helper {
    my ($name, $type, $data) = @_;

    if($type eq 'field') {
        $sth{insField}->execute(($name, $data));
    } elsif($type eq 'array') {
        my $idx = 0;
        foreach (@{ $data }) {
            $sth{insArrayElement}->execute(($name, $idx, $_));
            ++$idx;
        }
    } elsif($type eq 'wave') {
        foreach (keys %{ $data }) {
            my $plotname = $_;
            my $idx = 0;
            foreach (@{ $data->{$plotname} }) {
                $sth{insWaveElement}->execute(($name, $plotname, $idx, $_));
                ++$idx;
            }
        }
    } elsif($type eq 'lambda') {
        my ($payload, $retType, $returnData) =
           (encode_json({
                plugin => $data->{plugin},
                config => $data->{config},
            }),
            $data->{return}->{type},
            $data->{return}->{value});
        $sth{insLambdaRef}->execute(($name, $retType, $payload));
        set_helper($name, $retType, $returnData);
    } else {
        die "invalid type: $type";
    }
}

package Core::Document;

use strict;
use warnings;

use JSON::PP;

sub new {
    my ($class, $path) = @_;
    my $self = {
        pluginPath => [ "./Plugins" ],
        dbCfg => {
            plugin => '',
            config => {},
        },
        chains => [],
    };

    bless $self, $class;

    if(defined $path) {
        $self->load($path);
    }

    return bless $self, $class;
}

sub load {
    my $self = shift;
    my ($path) = @_;

    if(!defined $path) {
        $self->{pluginPath} = [ "./Plugins" ]; # also, the ones passed as arguments
        $self->{dbCfg} = {
            plugin => '',
            config => {},
        };
        $self->{chains} = [];

        return 1;
    } else {
        print "loading from $path\n";
        my $ok = 1;
        open A, "<$path" or $ok = 0;
        if(!$ok) {
            print "cannot open $path for reading\n";
            return 0;
        }

        my $s = "";
        while(<A>) {
            $s .= $_;
        }

        my %model = %{ decode_json($s) };
        $self->{pluginPath} = $model{pluginPath};
        $self->{dbCfg} = $model{dbCfg};
        $self->{chains} = $model{chains};

        # check model sort-of schema
        if(!$self->check()) {
            print "model check failed\n";
            $self->{pluginPath} = [ "./Plugins" ];
            $self->{dbCfg} = {
                plugin => '',
                config => {},
            };
            $self->{chains} = [];
            return 0;
        }

        return 1;
    }
}

sub save {
    my $self = shift;
    my ($path) = @_;
    
    my $ok = 1;
    open A, ">$path" or $ok = 0;
    if(!$ok) {
        print "cannot open $path for writing\n";
        return 0;
    }

    my %model = (
        pluginPath => $self->{pluginPath},
        dbCfg => $self->{dbCfg},
        chains => $self->{chains},
    );

    my $s = encode_json(\%model);

    print A $s or $ok = 0;
    if(!$ok) {
        print "cannot open $path for writing\n";
        return 0;
    }

    close A;

    return 1;
}

sub check {
    my ($self) = @_;
    return ref $self->{pluginPath} eq 'ARRAY'
        && ref $self->{dbCfg} eq 'HASH'
        && ref $self->{chains} eq 'ARRAY'
        && defined $self->{dbCfg}->{plugin}
        && defined $self->{dbCfg}->{config}
        ;
}

1;

#!/usr/bin/env perl
# TODO
# outline:
#   process command line args (load document, set additional plugin paths)
#   set up document model
#   foreach (@pluginPath) { PluginManager::load($_); }
#   show window
#   main loop

use warnings;
use strict;

use UI::PeeleApplication;
use Core::PluginManager;
use JSON::PP;

my %model = (
    pluginPath => [ "./Plugins" ],
    dbCfg => {
        plugin => '',
        config => {},
    },
    chains => ['test'],
);

# TODO cmd line args && set plugin path

# initial load plugins
foreach (@{ $model{pluginPath} }) {
    PluginManager::load($_);
}

# present main window && enter loop
PeeleApplication->new(\%model, \&new_model, \&save_model)->MainLoop;

sub new_model {
    my ($path, $o) = @_;

    if(!defined $path) {
        %model = (
            pluginPath => [ "./Plugins" ], # also, the ones passed as arguments
            dbCfg => {
                plugin => '',
                config => {},
            },
            chains => [],
        );

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

        %model = %{ decode_json($s) };

        # check model sort-of schema
        return check_model();
    }
}

sub save_model {
    my ($path) = @_;
    
    my $ok = 1;
    open A, ">$path" or $ok = 0;
    if(!$ok) {
        print "cannot open $path for writing\n";
        return 0;
    }

    my $s = encode_json(\%model);

    print A $s or $ok = 0;
    if(!$ok) {
        print "cannot open $path for writing\n";
        return 0;
    }

    close A;

    return 1;
}

sub check_model {
    return defined $model{pluginPath}
        && defined $model{dbCfg}
        && defined $model{chains};
}

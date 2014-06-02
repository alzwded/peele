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
PeeleApplication->new(\%model, \&new_model)->MainLoop;

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
    } else {
        print $path;
        print "      ".$o;
        ... # TODO load model from file
    }
}

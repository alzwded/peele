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
use Core::Document;

my $model = Document->new();

# TODO cmd line args && set plugin path

# initial load plugins
foreach (@{ $model->{pluginPath} }) {
    PluginManager::load($_);
}

# present main window && enter loop
PeeleApplication->new($model)->MainLoop;

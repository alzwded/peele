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

# TODO cmd line args && set plugin path

my ($path) = @ARGV;
die "invalid path $path" unless !defined($path) || -f $path;

my $model = Core::Document->new($path);

# initial load plugins
foreach (@{ $model->{pluginPath} }) {
    Core::PluginManager::load($_);
}

# present main window && enter loop
UI::PeeleApplication->new($model)->MainLoop;

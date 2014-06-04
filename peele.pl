#!/usr/bin/env perl

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

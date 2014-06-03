#!/usr/bin/perl -w

use strict;
use Core::PluginManager;

# it should be possible to call it twice in a row, w/o side effect, as per requirements
Core::PluginManager::load("./testPlugs/");
Core::PluginManager::load("./testPlugs/");

foreach (keys %Core::PluginManager::fplugins) {
    my $thing = $_->new();
    $thing->apply();
}

foreach (keys %Core::PluginManager::dplugins) {
    $_->open();
}

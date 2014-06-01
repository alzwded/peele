#!/usr/bin/perl -w

use Core::PluginManager;

# it should be possible to call it twice in a row, w/o side effect, as per requirements
PluginManager::load("./testPlugs/");
PluginManager::load("./testPlugs/");

foreach (keys %PluginManager::fplugins) {
    my $thing = $_->new();
    $thing->apply();
}

foreach (keys %PluginManager::dplugins) {
    $_->open();
}

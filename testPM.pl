#!/usr/bin/perl -w

use Core::PluginManager;

PluginManager::load("./testPlugs/");

foreach (@PluginManager::fplugins) {
    my $thing = $_->new();
    $thing->apply();
}

foreach (@PluginManager::dplugins) {
    $_->open();
}

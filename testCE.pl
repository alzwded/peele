#!/usr/bin/perl

use UI::ChainEditor;

use Core::DBEngine;
use Data::Dumper;
use Core::PluginManager;

Core::PluginManager::load("./Plugins");
Core::PluginManager::load("./testPlugs");

my $plugin = "SQLiteDB";
my %configHash = $plugin->default_parameters();
my $config = \%configHash;
my $dbCfg = {
    plugin => "SQLiteDB",
    config => $config,
};

my $db = Core::DBEngine->new($dbCfg);

my $ce = UI::ChainEditor->new([ ['a', 'b', { c=>'d'}, 'e']], $db);
$ce->ShowModal();
$ce->Destroy();

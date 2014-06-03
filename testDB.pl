#!/usr/bin/perl -w

use Core::DBEngine;
use Data::Dumper;
use Core::PluginManager;

Core::PluginManager::load("./Plugins");

my $plugin = "SQLiteDB";
my %configHash = $plugin->default_parameters();
my $config = \%configHash;
my $dbCfg = {
    plugin => "SQLiteDB",
    config => $config,
};

print Dumper($dbCfg);

testGet();
testSet();
testZap();


sub testGet {
    my $db = Core::DBEngine->new($dbCfg);
    my $v;
    print "f1 ";
    $v = $db->get('f1'); print Dumper($v);
    print "a2 ";
    $v = $db->get('a2'); print Dumper($v);
    print "w3 ";
    $v = $db->get('w3'); print Dumper($v);
    print "l4 ";
    $v = $db->get('l4'); print Dumper($v);
    print "l5 ";
    $v = $db->get('l5'); print Dumper($v);
}

sub testSet {
    my $db = Core::DBEngine->new($dbCfg);
    my $v;
    print "before: ";
    print Dumper($db->get('l4'));
    $db->set('l4', {
        value => 'works',
        type => 'field',
    });
    print "after: ";
    print Dumper($db->get('l4'));
}

sub testZap {
    my $db = Core::DBEngine->new($dbCfg);
    my $v;
    print "before: ";
    $db->set('del', {
        value => 'ephemeral',
        type => 'field',
    });
    print Dumper($db->get('del'));
    print "after: ";
    $db->set('del', undef);
    print Dumper($db->get('del'));
}

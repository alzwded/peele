package Core::DBEngine;

use strict;
use warnings;

sub new {
    my $class = shift;
    my ($plugin, $dbCfg) = @_;
    my $self = {
        plugin => $dbCfg->{plugin},
    };
    $plugin->open($dbCfg->{config});
    return bless $self, $class;
}

sub DESTROY {
    my ($self) = @_;

    $self->{plugin}->close();
}

sub get {
    my ($self, $varName) = @_;

    my %rez = $self->{plugin}->get($varName);

    return %rez;
}

sub set {
    my ($self, $varName, %value) = @_;

    $self->{plugin}->set($varName, %value);
}

1;

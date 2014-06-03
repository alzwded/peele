package Core::DBEngine;

use Core::PluginManager;

use strict;
use warnings;

sub new {
    my $class = shift;
    my ($dbCfg) = @_;
    my $plugin = $dbCfg->{plugin};
    my $self = {
        plugin => $plugin,
    };
    $plugin->open($dbCfg->{config});
    return bless $self, $class;
}

sub DESTROY {
    my ($self) = @_;

    $self->{plugin}->close();
}

use Data::Dumper;
sub get {
    my ($self, $varName) = @_;

    my ($defnd, %rez) = $self->{plugin}->get($varName);

    return \%rez if $defnd;

    return undef;
}

sub set {
    my ($self, $varName, $value) = @_;

    $self->{plugin}->set($varName, $value);
}

1;

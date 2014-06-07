package Select;

use strict;
use warnings;

# usage:
# input1 -> select { w1, w2, w3, ..., wN } -> %l
# input2 -> %l
# input3 -> %l
# ...
# inputN -> %l
# %l -> output

sub new {
    my ($class, $cfg) = @_;
    my $self = { waves => {} };
    if(ref $cfg eq 'HASH') {
        from_cfg($self, $cfg);
    }
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'wave') {
        my @newKeys = @{ $self->{select} };
        my $return = {
            type => 'wave',
            value => {
            },
        };
        my $name = shift @newKeys;
        my $newCfg = {
            '@__select__' => \@newKeys,
        };
        foreach (keys %{ $self->{waves} }) {
            my $key = $_;
            $newCfg->{'@'.$key} = $self->{waves}->{$key};
            $return->{value}->{$key} = $self->{waves}->{$key};
        }
        $newCfg->{'@'.$name} = $x->{value}->{$name};
        $return->{value}->{$name} = $x->{value}->{$name};
        return {
            type => 'lambda',
            value => {
                plugin => 'Select',
                config => $newCfg,
                return => $return,
            },
        };
    } elsif($x->{type} eq 'array') {
        my @newKeys = @{ $self->{select} };
        my $return = {
            type => 'wave',
            value => {
            },
        };
        my $name = shift @newKeys;
        my $newCfg = {
            '@__select__' => \@newKeys,
        };
        foreach (keys %{ $self->{waves} }) {
            my $key = $_;
            $newCfg->{'@'.$key} = $self->{waves}->{$key};
            $return->{value}->{$key} = $self->{waves}->{$key};
        }
        $newCfg->{'@'.$name} = $x->{value};
        $return->{value}->{$name} = $x->{value};
        return {
            type => 'lambda',
            value => {
                plugin => 'Select',
                config => $newCfg,
                return => $return,
            },
        };
    } else {
        my @newKeys = @{ $self->{select} };
        my $return = {
            type => 'wave',
            value => {
            },
        };
        my $name = shift @newKeys;
        my $newCfg = {
            '@__select__' => \@newKeys,
        };
        foreach (keys %{ $self->{waves} }) {
            my $key = $_;
            $newCfg->{'@'.$key} = $self->{waves}->{$key};
            $return->{value}->{$key} = $self->{waves}->{$key};
        }
        return {
            type => 'lambda',
            value => {
                plugin => 'Select',
                config => $newCfg,
                value => $return,
            },
        };
    }
}

sub default_parameters {
    return {
        '@waveNames' => [],
    };
}

sub from_cfg {
    my ($self, $cfg) = @_;
    if(defined $cfg->{'@waveNames'}) {
        $self->{select} = $cfg->{'@waveNames'};
    } else {
        $self->{waves} = {};
        foreach (keys %{ $cfg }) {
            next if $_ eq '@__select__';
            my $newKey = substr $_, 1;
            $self->{waves}->{$newKey} = $cfg->{$_};
        }
        $self->{select} = $cfg->{'@__select__'};
    }
}

1;

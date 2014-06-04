package testa;

sub new {
    my ($class, $cfg) = @_;
    my $self = { value => $cfg->{'$value'} };
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    use Data::Dumper;
    print Dumper $x;
    if($x->{type} eq 'array') {
        my $val = scalar @{ $x->{value} };
        my @r = ();
        for(my $i = 0; $i < 10; ++$i) {
            push @r, $i * $val;
        }
        return {
            type => 'array',
            value => \@r,
        }
    } else {
        return {
            type => 'array',
            value => [],
        }
    }
}

sub default_parameters {
    return {
        '$value' => 1,
    };
}

1;

package testb;

sub new {
    my ($class, $cfg) = @_;
    my $self = { value => $cfg->{'$value'} };
    use Data::Dumper;
    print Dumper $cfg, $self;
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'array') {
        use Data::Dumper;
        print Dumper $x->{value};
        my @r = map { $_ * $self->{value} } @{ $x->{value} };
        print Dumper $self, @r;
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

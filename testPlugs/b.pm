package b;

sub new {
    my ($class, $cfg) = @_;
    my $self = { value => $cfg->{value} };
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'array') {
        my @r = map { $_ * $self->{value} } @{ $x->{value} };
        return \@r;
    } else {
        return [];
    }
}

sub default_parameters {
    return {
        '$value' => 1;
    };
}

1;

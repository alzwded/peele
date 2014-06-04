package a;

sub new {
    my ($class, $cfg) = @_;
    my $self = { value => $cfg->{value} };
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'field') {
        my @r = ();
        for(my $i = 0; $i < 10; ++$i) {
            push @r, $i * $self->{value};
        }
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

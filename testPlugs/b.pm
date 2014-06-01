package b;

sub new {
    my $self = { val => 1 }; bless $self;
    return $self;
}

sub apply {
    my ($self) = @_;
    print "b $self->{val}\n";
}

sub default_parameters {}

1;

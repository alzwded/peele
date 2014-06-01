package a;

sub new {
    my $self = { val => 1 }; bless $self;
    return $self;
}

sub apply {
    my ($self) = @_;
    print "a $self->{val}\n";
}

sub default_parameters {}

1;

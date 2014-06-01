package Module::b;

sub new {
    my $self = { val => 2 }; bless $self;
    return $self;
}

sub apply {
    my ($self) = @_;
    print "Module::b $self->{val}\n";
}

sub default_parameters {}

1;

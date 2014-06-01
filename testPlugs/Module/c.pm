package Module::c;

sub new {
    die 'fail';
    my $self = { val => 1 }; bless $self;
    return $self;
}

sub appl {
    my ($self) = @_;
    print "b $self->{val}\n";
}

1;

package UI::Components::FieldEditor;
use base qw/Wx::BoxSizer/;
use Wx;
use Wx qw/:sizer wxDefaultPosition/;

sub new {
    my( $class, $parent, $name, $initial, $editFn ) = @_;
    my $self = $class->SUPER::new( &Wx::wxHORIZONTAL );

    my $label = Wx::StaticText->new($parent, -1, $name, &Wx::wxDefaultPosition, [-1, -1], 0);
    my $edit = Wx::TextCtrl->new($parent, -1, $initial, &Wx::wxDefaultPosition, [-1, -1], &Wx::wxTE_PROCESS_ENTER);
    $self->Add($label, 1, &Wx::wxALL | &Wx::wxALIGN_CENTER_VERTICAL, 5);
    $self->Add($edit, 1, &Wx::wxALL, 5);
    my $cb = sub {
        my ($tf, $evt) = @_;
        my $nextText = &{ $editFn }($tf->GetValue());
        if($nextText ne $tf->GetValue()) {
            $tf->ChangeValue($nextText);
        }
    };
    Wx::Event::EVT_TEXT_ENTER($edit, -1, $cb);
    Wx::Event::EVT_KILL_FOCUS($edit, $cb);

    return $self;
}

1;

package UI::Components::FieldEditor;
use base qw/Wx::BoxSizer/;
use Wx;
use Wx qw/:sizer wxDefaultPosition/;

# Field generic UI component
# name => the name to be displayed
# initial => the initial value
# editFn => lambda(string) -> string ;
#     called when the value in the text box is changed (focus lost or RET pressed)
#     the return value will be used as the new display value
sub new {
    my( $class, $parent, $name, $initial, $editFn ) = @_;
    my $self = $class->SUPER::new( &Wx::wxHORIZONTAL );

    my $label = Wx::StaticText->new($parent, -1, $name, &Wx::wxDefaultPosition, [-1, -1], 0);
    $self->Add($label, 1, &Wx::wxALL | &Wx::wxALIGN_CENTER_VERTICAL, 5);

    my $edit = Wx::TextCtrl->new($parent, -1, $initial, &Wx::wxDefaultPosition, [-1, -1], &Wx::wxTE_PROCESS_ENTER);
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

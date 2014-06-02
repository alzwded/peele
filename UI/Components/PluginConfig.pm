package UI::Components::PluginConfig;
use Wx;
use Wx qw/:sizer wxDefaultPosition wxDefaultSize/;
use base qw/Wx::Dialog/;
use UI::Components::FieldEditor;
use UI::Components::ListEditor;
use Wx::Event qw/EVT_BUTTON/;

# Field generic UI component
# name => the name to be displayed
# initial => the initial value
# editFn => lambda(string) -> string ;
#     called when the value in the text box is changed (focus lost or RET pressed)
#     the return value will be used as the new display value
sub new {
    my( $class, $parent, $data ) = @_;

    my $self = $class->SUPER::new( undef, -1, 'Edit config', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxDEFAULT_DIALOG_STYLE );

    my $sizer = Wx::BoxSizer->new( &Wx::wxVERTICAL );

    foreach (keys %$data) {
        my $key = $_;
        $key =~ m/(.)(.*)/;
        my $type = $1;
        my $name = $2;

        if($type eq '$') {
            my $component = UI::Components::FieldEditor->new($self, $name, $data->{$key}, sub {
                my ($value) = @_;
                $data->{$key} = $value;
                return $value;
            });
            $sizer->Add($component, 0, &Wx::wxEXPAND);
        } elsif($type eq '@') {
            my $component = UI::Components::ListEditor->new($self, $name, $data->{$key}, 
                # add
                sub {
                    my $davalue;

                    my $f = Wx::Dialog->new($self, -1, 'Add string');
                    my $s = Wx::BoxSizer->new(&Wx::wxVERTICAL);

                    my $tf = UI::Components::FieldEditor->new($f, 'Value', '', 
                        sub {
                            my ($v) = @_;
                            $davalue = $v;
                            return $v;
                        });
                    $s->Add($tf, 0, &Wx::wxEXPAND);

                    my $s2 = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
                    my $ok = Wx::Button->new($f, -1, 'Okay', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, 0);
                    my $cancel = Wx::Button->new($f, -1, 'Cancel', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, 0);
                    $s2->Add($ok, 0, &Wx::wxRIGHT);
                    $s2->Add($cancel, 0, &Wx::wxRIGHT);
                    Wx::Event::EVT_BUTTON($ok, -1, sub {
                        $f->EndModal(&Wx::wxID_OK);
                    });
                    Wx::Event::EVT_BUTTON($cancel, -1, sub {
                        $f->EndModal(&Wx::wxID_CANCEL);
                    });
                    $s->Add($s2, 0, &Wx::wxEXPAND);

                    $f->SetSizer($s);

                    if($f->ShowModal() == &Wx::wxID_OK) {
                        push $data->{$key}, $davalue;
                        $f->Destroy();
                        return $davalue;
                    } else {
                        $f->Destroy();
                    }
                },
                # edit
                sub {
                    ...
                },
                # delete
                sub {
                    ...
                });
            $sizer->Add($component, 0, &Wx::wxEXPAND);
        } else {
            die "field is not in correct format: $type";
        }
    }
        
    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);

    return $self;
}

1;
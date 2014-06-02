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
                    my $davalue = '';
                    my $f = editor_dialog($self, 'Adding...', \$davalue);
                    print "val: $davalue\n";

                    if($f->ShowModal() == &Wx::wxID_OK) {
                        push $data->{$key}, $davalue;
                        $f->Destroy();
                        return $davalue;
                    } else {
                        $f->Destroy();
                        return undef;
                    }
                },
                # edit
                sub {
                    my ($idx) = @_;
                    my $davalue = $data->{$key}[$idx];
                    my $f = editor_dialog($self, 'Adding...', \$davalue);
                    print "val: $davalue\n";

                    if($f->ShowModal() == &Wx::wxID_OK) {
                        $data->{$key}[$idx] = $davalue;
                        $f->Destroy();
                        return $davalue;
                    } else {
                        $f->Destroy();
                        return $data->{$key}[$idx];
                    }
                },
                # delete
                sub {
                    my ($idx) = @_;
                    my $s = $data->{$key}[$idx];
                    if (Wx::MessageBox(
                                "Delete '$s'?",
                                'Confirm',
                                &Wx::wxYES_NO,
                                $frame)
                            == &Wx::wxYES)
                    {
                        splice $data->{$key}, $idx, 1;
                        return 1;
                    } else {
                        return 0;
                    }
                });
            $sizer->Add($component, 0, &Wx::wxEXPAND);
        } else {
            die "field is not in correct format: ${type}$name";
        }
    }
        
    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);

    return $self;
}

sub editor_dialog {
    my ($owner, $title, $valueRef) = @_;

    my $f = Wx::Dialog->new($owner, -1, $title);
    my $s = Wx::BoxSizer->new(&Wx::wxVERTICAL);

    my $tf = UI::Components::FieldEditor->new($f, 'Value', $$valueRef, 
        sub {
            my ($v) = @_;
            $$valueRef = $v;
            print "$v vs $$valueRef vs $valueRef\n";
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

    return $f;
}

1;

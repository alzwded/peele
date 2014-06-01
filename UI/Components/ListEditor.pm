package UI::Components::ListEditor;
use base qw/Wx::StaticBoxSizer/;
use Wx;
use Wx qw/:sizer wxDefaultPosition/;

sub new {
    my( $class, $parent, $name, $initial, $createFn, $editFn, $delFn ) = @_;
    my $self = $class->SUPER::new( 
        Wx::StaticBox->new($parent, -1, $name),
        &Wx::wxHORIZONTAL);

    # add listbox
    my $list = Wx::ListBox->new($parent, -1,
        &Wx::wxDefaultPosition,
        &Wx::wxDefaultSize,
        $initial,
        &Wx::wxGROW|&Wx::wxLB_SINGLE);
    $self->Add($list, 1, &Wx::wxALL|&Wx::wxEXPAND, 5);

    # add buttonSizer
    my $buttonSizer = Wx::BoxSizer->new( &Wx::wxVERTICAL );
    my $addBtn = Wx::Button->new($parent, -1, '+', &Wx::wxDefaultPosition, [25, 25]);
    my $delBtn = Wx::Button->new($parent, -1, '-', &Wx::wxDefaultPosition, [25, 25]);
    my $editBtn = Wx::Button->new($parent, -1, '?', &Wx::wxDefaultPosition, [25, 25]);

    Wx::Event::EVT_BUTTON($parent, $addBtn, sub {
        $list->Append(&{ $createFn });
    });
    Wx::Event::EVT_BUTTON($parent, $editBtn, sub {
        my $sel = $list->GetSelection();
        if($sel != &Wx::wxNOT_FOUND) {
            my $newString = &{ $editFn }($sel);
            $list->SetString($sel, $newString);
        }
    });
    Wx::Event::EVT_BUTTON($parent, $delBtn, sub {
        my $sel = $list->GetSelection();
        if($sel != &Wx::wxNOT_FOUND) {
            if(&{ $delFn }($sel)) {
                $list->Delete($sel);
            }
        }
    });

    $buttonSizer->Add($addBtn, 0, &Wx::wxALL, 5);
    $buttonSizer->Add($delBtn, 0, &Wx::wxALL, 5);
    $buttonSizer->Add($editBtn, 0, &Wx::wxALL, 5);

    $self->Add($buttonSizer, 0, &Wx::wxALL, 5);

    return $self;
}

1;

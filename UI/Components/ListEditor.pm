package UI::Components::ListEditor;
use base qw/Wx::StaticBoxSizer/;
use Wx;
use Wx qw/:sizer wxDefaultPosition/;

# ListBox generic component
# name => the name of the attribute to be displayed
# initial => the initial list items
# createFn => lambda() -> string ; the return val will be the ID of the new item
# editFn => lambda(int) -> string ; edit the item at the index and return the new string that will be displayed in this item's place
# delFn => lambda(int) -> bool ; return true if the item was deleted
sub new {
    my( $class, $parent, $name, $initial, $createFn, $editFn, $delFn ) = @_;
    my $self = $class->SUPER::new( 
        Wx::StaticBox->new($parent, -1, $name),
        &Wx::wxHORIZONTAL);

    # add listbox
    my $list = Wx::ListBox->new($parent, -1,
        &Wx::wxDefaultPosition,
        &Wx::wxDefaultSize,
        $initial || [],
        &Wx::wxGROW|&Wx::wxLB_SINGLE);
    $self->Add($list, 1, &Wx::wxALL|&Wx::wxEXPAND, 5);

    # add buttonSizer
    my $buttonSizer = Wx::BoxSizer->new( &Wx::wxVERTICAL );
    my $addBtn = Wx::Button->new($parent, -1, '+', &Wx::wxDefaultPosition, [25, 25]);
    my $delBtn = Wx::Button->new($parent, -1, '-', &Wx::wxDefaultPosition, [25, 25]);
    my $editBtn = Wx::Button->new($parent, -1, '?', &Wx::wxDefaultPosition, [25, 25]);

    Wx::Event::EVT_BUTTON($parent, $addBtn, sub {
        my $s = &{ $createFn };
        if(defined $s) { $list->Append($s); }
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

    return bless $self, $class;
}

sub Clear {
    my ($self) = @_;
    my $lb = $self->GetItem(0)->GetWindow();
    $lb->Clear;
}

sub GetLB {
    my ($self) = @_;
    my $lb = $self->GetItem(0)->GetWindow();
    return $lb;

}

sub GetAddBtn {
    my ($self) = @_;
    return $self->GetItem(1)->GetSizer()->GetItem(0)->GetWindow();
}

sub GetEditBtn {
    my ($self) = @_;
    return $self->GetItem(1)->GetSizer()->GetItem(2)->GetWindow();
}

sub GetDelBtn {
    my ($self) = @_;
    return $self->GetItem(1)->GetSizer()->GetItem(1)->GetWindow();
}

1;

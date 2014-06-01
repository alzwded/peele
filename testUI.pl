#!/usr/bin/perl -w

use warnings;
use strict;

use Wx;
use wxPerl::Constructors;

use UI::Components::FieldEditor;

package MyApp;

use base 'Wx::App';

our $THEVALUE = 1;

sub OnInit {
    my $self = shift;

    my $frame = wxPerl::Frame->new(undef, 'A wxPerl Application',
            style => &Wx::wxMAXIMIZE_BOX | &Wx::wxCLOSE_BOX | &Wx::wxRESIZE_BORDER
            );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);

    my $tedit1 = UI::Components::FieldEditor->new($frame, 'field1', '1', sub {
        my ($nextValue) = @_;
        if($nextValue >= 0) {
            $THEVALUE = $nextValue;
            print "$THEVALUE\n";
            return $nextValue;
        } else {
            print "$THEVALUE\n";
            return $THEVALUE;
        }
    });

    $sizer->Add($tedit1, 0, &Wx::wxEXPAND);

    my $tedit2 = UI::Components::FieldEditor->new($frame, 'field2 hahaha', '0', sub {
        return 0;
    });
    $sizer->Add($tedit2, 0, &Wx::wxEXPAND);

    $frame->SetSizer($sizer);
    $frame->Show;

    #my $otherFrame = Wx::DemoModules::wxBoxSizer->new();
    #$otherFrame->Show;
}

MyApp->new->MainLoop;

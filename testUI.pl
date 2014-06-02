#!/usr/bin/perl -w

use warnings;
use strict;

use Wx;
use wxPerl::Constructors;

use UI::Components::FieldEditor;
use UI::Components::ListEditor;
use UI::DBPicker;

package MyApp;

use base 'Wx::App';

our $THEVALUE = 1;

my %mockModel = (
    dbCfg => {
        plugin => 'dbThing',
        config => {},
    }
);

sub OnInit {
    Core::PluginManager::load("./testPlugs");

    my $self = shift;

    my $frame = wxPerl::Frame->new(undef, 'A wxPerl Application',
            style => &Wx::wxDEFAULT_FRAME_STYLE | &Wx::wxRESIZE_BORDER
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

    my $lb = UI::Components::ListEditor->new($frame,
        'Array item',
        ["element 1", "element 2", "element last"], 
        sub {
            print "added item?\n";
            return $THEVALUE;
        },
        sub {
            my ($d) = @_;
            print "modified item $d?\n";
            return $THEVALUE;
        },
        sub {
            my ($d) = @_;
            return (Wx::MessageBox(
                'Delete item no. '.($d + 1).'?',
                'Confirm',
                &Wx::wxYES_NO,
                $frame)
                == &Wx::wxYES);
        });
    $sizer->Add($lb, 0, &Wx::wxEXPAND);

    my $dbpicker = UI::DBPicker->new($frame, \%mockModel);
    $sizer->Add($dbpicker, 0, &Wx::wxEXPAND);

    $frame->SetSizer($sizer);
    $frame->Show;
}

MyApp->new->MainLoop;

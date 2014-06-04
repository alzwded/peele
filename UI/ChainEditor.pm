package UI::ChainEditor;

use Wx;
use Wx::Event;

use Core::PluginManager;
use Core::DBEngine;

use base qw/Wx::Dialog/;

use warnings;
use strict;

<<EOT
yCombo events -> set chain[idx]
EOT
;

sub new {
    my ($class, $chain, $db) = @_;
    my $self = $class->SUPER::new(undef, -1, 'Chain', &Wx::wxDefaultPosition, [775, -1], &Wx::wxDEFAULT_DIALOG_STYLE|&Wx::wxRESIZE_BORDER);

    my $sb = Wx::ScrolledWindow->new($self, -1, &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxVSCROLL);

    my $sizer = Wx::FlexGridSizer->new(1, 6, 5, 5);
    $sizer->AddGrowableCol(0);
    $sizer->AddGrowableCol(2);
    $sizer->AddGrowableCol(4);

    # init
    $sizer->Add(Wx::StaticText->new($sb, -1, 'y', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxALIGN_CENTER_HORIZONTAL), 1, &Wx::wxEXPAND);
    $sizer->Add(Wx::StaticText->new($sb, -1, '=', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, 0), 0, &Wx::wxEXPAND);
    $sizer->Add(Wx::StaticText->new($sb, -1, 'f', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxALIGN_CENTER_HORIZONTAL), 1, &Wx::wxEXPAND);
    $sizer->Add(Wx::StaticText->new($sb, -1, '(', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, 0), 0, &Wx::wxEXPAND);
    $sizer->Add(Wx::StaticText->new($sb, -1, 'x', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxALIGN_CENTER_HORIZONTAL), 1, &Wx::wxEXPAND);
    $sizer->Add(Wx::StaticText->new($sb, -1, ')', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, 0), 0, &Wx::wxEXPAND);

    my @dbVars = map { "%$_"; } @{ $db->get_all() };
    my @fVars = keys %Core::PluginManager::fplugins;
    foreach (@dbVars) {
        my $var = $_;
        my $dbv = $db->get(substr $var, 1);
        if($dbv->{type} eq 'lambda') {
            push @fVars, $var;
        }
    }

    my $addBtn = Wx::Button->new($sb, -1, '+', &Wx::wxDefaultPosition, [25, 25]);
    $sizer->Add($addBtn, 0, 0);
    Wx::Event::EVT_BUTTON($addBtn, -1, sub {
        my $newChain = ['', '', {}, ''];
        push $chain, $newChain;
        add_controls($newChain, $chain, (scalar @$chain) - 1, $self, $sb, $sizer, \@dbVars, \@fVars);
        $sizer->Layout();
        $sb->FitInside();
    });

    my $idx = 0;

    for(my $idx = 0; $idx < scalar @$chain; ++$idx) {
        my $func = @$chain[$idx];
        add_controls($func, $chain, $idx, $self, $sb, $sizer, \@dbVars, \@fVars);
    }

    $sb->SetSizer($sizer);
    $sb->FitInside();
    $sb->SetScrollRate(5, 5);

    my $fu = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $fu->Add($sb, 1, &Wx::wxEXPAND);
    $self->SetSizer($fu);
    $self->SetAutoLayout(1);
    return $self;
}

sub add_controls {
    my ($func, $chain, $chainIdx, $dialog, $sb, $sizer, $dbVars, $fVars) = @_;
    my $idx = (1 + $chainIdx) * 6;
    my ($y, $f, $cfg, $x) = @$func;

    my $yCombo = Wx::ComboBox->new($sb, -1, $y, &Wx::wxDefaultPosition, &Wx::wxDefaultSize,
        $dbVars,
        &Wx::wxTE_PROCESS_ENTER);
    $sizer->Insert($idx++, $yCombo, 1, &Wx::wxEXPAND);
    add_events_for_combo($yCombo, sub {
        @$func[0] = $yCombo->GetValue();
    });

    my $text = Wx::StaticText->new($sb, -1, '=', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, 0);
    $sizer->Insert($idx++, $text, 0, &Wx::wxEXPAND);

    my $fCombo = Wx::ComboBox->new($sb, -1, $f, &Wx::wxDefaultPosition, &Wx::wxDefaultSize, $fVars, &Wx::wxTE_PROCESS_ENTER);
    $sizer->Insert($idx++, $fCombo, 1, &Wx::wxEXPAND);
    add_events_for_combo($fCombo, sub {
        @$func[1] = $fCombo->GetValue();
        if(defined $Core::PluginManager::fplugins{@$func[1]}) {
            @$func[2] = @$func[1]->default_parameters();
        } else {
            @$func[2] = {};
        }
    });

    my $fCfgBtn = Wx::Button->new($sb, -1, '?', &Wx::wxDefaultPosition, [25, 25]);
    $sizer->Insert($idx++, $fCfgBtn, 0, &Wx::wxEXPAND);
    Wx::Event::EVT_BUTTON($fCfgBtn, -1, sub {
        my $data = @$func[2] || {};
        my $pluginConfiger = UI::Components::PluginConfig->new($sb, $data);
        $pluginConfiger->ShowModal();
        $pluginConfiger->Destroy();
    });

    my $xCombo = Wx::ComboBox->new($sb, -1, $x, &Wx::wxDefaultPosition, &Wx::wxDefaultSize, $dbVars, &Wx::wxTE_PROCESS_ENTER);
    $sizer->Insert($idx++, $xCombo, 1, &Wx::wxEXPAND);
    add_events_for_combo($xCombo, sub {
        @$func[3] = $xCombo->GetValue();
    });

    my $delBtn = Wx::Button->new($sb, -1, '-', &Wx::wxDefaultPosition, [25, 25]);
    $sizer->Insert($idx++, $delBtn, 0, &Wx::wxEXPAND);
    Wx::Event::EVT_BUTTON($delBtn, -1, sub {
        if(Wx::MessageBox(
                "Are you sure you want to delete this element?",
                'Confirm',
                &Wx::wxYES_NO,
                $dialog)
            == &Wx::wxYES)
        {
            $sizer->Hide($yCombo);
            $sizer->Hide($xCombo);
            $sizer->Hide($fCombo);
            $sizer->Hide($fCfgBtn);
            $sizer->Hide($delBtn);
            $sizer->Hide($text);
            $sizer->Remove($yCombo);
            $sizer->Remove($xCombo);
            $sizer->Remove($fCombo);
            $sizer->Remove($fCfgBtn);
            $sizer->Remove($delBtn);
            $sizer->Remove($text);
            $sizer->Layout();
            $sb->FitInside();
            for(my $i = 0; $i < scalar @$chain; ++$i) {
                if($func == @$chain[$i]) {
                    splice $chain, $i, 1;
                    last;
                }
            }
        }
    });
}

sub add_events_for_combo {
    my ($combo, $cb) = @_;

    Wx::Event::EVT_TEXT_ENTER($combo, -1, $cb);
    Wx::Event::EVT_KILL_FOCUS($combo, $cb);
    Wx::Event::EVT_COMBOBOX($combo, -1, $cb);
}

sub to_nice_string {
    my ($chain) = @_;
    my $len = scalar @$chain;
    if($len < 1) {
        return "<empty>";
    }
    my $s = @{ @$chain[0] }[3];
    foreach (@$chain) {
        $s .= " -> ".@{ $_ }[1];
    }
    $s .= " -> ".@{ @$chain[$len - 1] }[0];
    return $s;
}

1;

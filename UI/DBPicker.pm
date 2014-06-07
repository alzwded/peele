package UI::DBPicker;
use base qw/Wx::BoxSizer/;
use Wx;
use Wx qw/:sizer wxDefaultPosition wxDefaultSize/;
use Core::PluginManager;
use Wx::Event qw/EVT_BUTTON EVT_KILL_FOCUS EVT_COMBOBOX EVT_TEXT_ENTER EVT_SET_FOCUS/;
use UI::Components::PluginConfig;

use warnings;
use strict;

sub new {
    my( $class, $parent, $model ) = @_;
    my $self = $class->SUPER::new( &Wx::wxHORIZONTAL );

    my $label = Wx::StaticText->new($parent, -1, 'Database Engine', &Wx::wxDefaultPosition, [-1, -1], 0);
    $self->Add($label, 1, &Wx::wxALL | &Wx::wxALIGN_CENTER_VERTICAL, 5);

    my @initial = (keys %Core::PluginManager::dplugins) or ();
    my $combo = Wx::ComboBox->new($parent, -1, $model->{dbCfg}->{plugin}, &Wx::wxDefaultPosition, [-1, -1], 
        \@initial,
        &Wx::wxTE_PROCESS_ENTER);
    $self->Add($combo, 1, &Wx::wxALL, 5);

    my $cfgBtn = Wx::Button->new($parent, -1, '?', &Wx::wxDefaultPosition, [25, 25], 0);
    $self->Add($cfgBtn, 0, &Wx::wxALL, 5);

    my $cb = sub {
        my ($tf, $evt) = @_;
        my $text = $tf->GetValue();
        if(defined $Core::PluginManager::dplugins{$text}) {
            $model->{dbCfg}->{plugin} = $text;
            my $oldCfg = %{ $model->{dbCfg}->{config} };
            my $somewhatNewCfg = $text->default_parameters();
            # if cfg's are compatible, DO NOT REMOVE
            foreach (keys %{ $somewhatNewCfg }) {
                if(!defined $oldCfg->{$_}) {
                    %{ $model->{dbCfg}->{config} } = $somewhatNewCfg;
                }
            }
        } elsif($text ne '') {
            $tf->SetValue('');
        }
    };
    Wx::Event::EVT_TEXT_ENTER($combo, -1, $cb);
    Wx::Event::EVT_KILL_FOCUS($combo, $cb);
    Wx::Event::EVT_COMBOBOX($combo, -1, $cb);

    Wx::Event::EVT_BUTTON($cfgBtn, -1, sub {
        my $data = $model->{dbCfg}->{config};
        my $pluginConfiger = UI::Components::PluginConfig->new($parent, $data);
        $pluginConfiger->ShowModal();
        $pluginConfiger->Destroy();
    });

    Wx::Event::EVT_SET_FOCUS($combo, sub {
        $combo->Clear();
        foreach (keys %Core::PluginManager::dplugins) {
            $combo->Append($_);
        }
    });

    return $self;
}

1;

package UI::PluginSettings;

use warnings;
use strict;

use Wx;
use Wx qw/:sizer wxDefaultPosition wxDefaultSize/;
use base qw/Wx::Dialog/;
use UI::Components::ListEditor;
use UI::Components::PluginConfig;
use UI::DBPicker;
use Core::PluginManager;

sub new {
    my ($class, $parent, $model) = @_;

    my $self = $class->SUPER::new(undef, -1, 'Plugin Settings', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxDEFAULT_DIALOG_STYLE);
    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);

    my $pathsBox = UI::Components::ListEditor->new($self, 'Paths', $model->{pluginPath},
        # add
        sub {
            my $value = '';
            my $f = UI::Components::PluginConfig::editor_dialog('Add...', \$value);
            if($f->ShowModal() == &Wx::wxID_OK) {
                push $model->{pluginPath}, $value;
                Core::PluginManager::load($value);
                $f->Destroy();
                return $value;
            } else {
                $f->Destroy();
                return undef;
            }
        },
        # edit
        sub {
            my ($idx) = @_;
            my $value = $model->{pluginPath}[$idx];
            print "asd: $value\n";
            my $f = UI::Components::PluginConfig::editor_dialog('Edit...', \$value);
            if($f->ShowModal() == &Wx::wxID_OK) {
                $model->{pluginPath}[$idx] = $value;
                PluginManager::load($value);
                $f->Destroy();
                return $value;
            } else {
                $f->Destroy();
                return $model->{pluginPath}[$idx];
            }
        },
        # delete
        sub {
            my ($idx) = @_;
            my $s = $model->{pluginPath}[$idx];
            if (Wx::MessageBox(
                        "Delete '$s'?",
                        'Confirm',
                        &Wx::wxYES_NO,
                        $self)
                    == &Wx::wxYES)
            {
                splice $model->{pluginPath}, $idx, 1;
                return 1;
            } else {
                return 0;
            }
        });
    $sizer->Add($pathsBox, 0, &Wx::wxEXPAND);

    my $dbpicker = UI::DBPicker->new($self, $model);
    $sizer->Add($dbpicker, 0, &Wx::wxEXPAND);

    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);
    return $self;
}

1;

package UI::ProgressMonitor;

use Wx;
use Wx::Event;

use Core::PluginManager;
use Core::DBEngine;

use base qw/Wx::Dialog/;

use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');
use threads::shared;

use warnings;
use strict;

<<EOT
yCombo events -> set chain[idx]
EOT
;

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new(undef, -1, 'Running...', &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxCAPTION|&Wx::wxMINIMIZE_BOX|&Wx::wxSTAY_ON_TOP);

    my $sizer = Wx::BoxSizer->new( &Wx::wxVERTICAL );

    my $gauge = Wx::Gauge->new($self, -1, 100);
    $sizer->Add($gauge, 1, &Wx::wxEXPAND);

    my $cancel = Wx::Button->new($self, -1, 'Cancel');
    $sizer->Add($cancel, 1, &Wx::wxRIGHT);

    Wx::Event::EVT_BUTTON($cancel, -1, sub {
        &{ $self->{cancel_clicked} }();
    });

    $self->{update} = sub {
        my ($val) = @_;

        $gauge->SetValue($val);
    };

    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);
    return bless $self, $class;
}

sub run {
    my $self = shift;
    my $runMe = shift;
    my @params = @_;

    my $running :shared = 1;

    $self->{cancel_clicked} = sub {
        $running = 0;
    };

    my $thrd = threads->create(sub {
        threads->yield();
        &{ $runMe }(\$running, $self->{update}, @params);
        $self->EndModal($running);
    });

    $self->ShowModal();
    $thrd->join();
}

1;

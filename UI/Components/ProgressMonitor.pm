package UI::Components::ProgressMonitor;

use Wx;
use Wx::Event;

use base qw/Wx::Dialog/;

use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');
use threads::shared;

use warnings;
use strict;

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new(undef, -1, 'Running...', &Wx::wxDefaultPosition, [-1, 100], &Wx::wxCAPTION|&Wx::wxMINIMIZE_BOX|&Wx::wxSTAY_ON_TOP);

    my $sizer = Wx::BoxSizer->new( &Wx::wxVERTICAL );

    my $gauge = Wx::Gauge->new($self, -1, 100);
    $sizer->Add($gauge, 1, &Wx::wxEXPAND);

    my $cancel = Wx::Button->new($self, -1, 'Cancel');
    $sizer->Add($cancel, 1, &Wx::wxALIGN_RIGHT);

    Wx::Event::EVT_BUTTON($cancel, -1, sub {
        &{ $self->{cancel_clicked} }(); # we'll set this later because we don't know enough right now
    });

    $self->{update} = sub {
        my ($val) = @_;

        print "received $val\n";

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

    # shared variable; the task should know to stop itself ASAP whenever
    # this changes to false
    my $running :shared = 1;

    # set cancel-button-clicked callback that captures $running in its closure
    $self->{cancel_clicked} = sub {
        $running = 0;
    };

    # spawn a thread for the task
    my $thrd = threads->create(sub {
        threads->yield(); # immediately yield because we should really get to $self->ShowModal before the task actually starts; yeah yeah yeah, this is a Doing It Wrong, but it works most of the time;
        &{ $runMe }(\$running, $self->{update}, @params); # run the task, sending it the stop flag variable, the update routine and any parameters it needs
        sleep 1;
        $self->EndModal($running); # close the dialog; this also has the side effect of unblocking the main thread
    });

    $self->ShowModal(); # wait until someone closes the dialog
    $thrd->join();
}

1;

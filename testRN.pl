#!/usr/bin/perl -w

package TestRN;

use Wx;
use UI::ProgressMonitor;
use Wx::Event;


use base qw/Wx::App/;


sub task {
    my ($running, $update, $param) = @_;

    use Data::Dumper;
    print Dumper($running);
    print Dumper($$running);

    print "task: $param\n";

    for my $i (1..10) {
        sleep 1;
        print "$i\n";
        &{ $update }($i * 10);
        print Dumper($$running);
        last if !$$running;
    }
}

sub OnInit {
    my $f = Wx::Frame->new(undef, -1, 'Progress!', [-1, -1], [-1, -1], &Wx::wxDEFAULT_FRAME_STYLE);
    my $btn = Wx::Button->new($f, -1, 'Click me');
    Wx::Event::EVT_BUTTON($btn, -1, sub {
        my $pm = UI::ProgressMonitor->new();

        $pm->run(\&task, "message received");

        $pm->Destroy();
    });

    $f->Show();
}

TestRN->new->MainLoop;

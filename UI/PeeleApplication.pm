package PeeleApplication;

use Wx;
use wxPerl::Constructors;
use Wx::Event qw/EVT_MENU/;
use Wx::Menu;

use UI::Components::ListEditor;

use warnings;
use strict;
use base 'Wx::App';

our @ISA = qw/Wx::App/;

our %menuIds = (
    newm => 0,
    open => 1,
    save => 2,
    run => 3,
    results => 4,
    exit => &Wx::wxID_EXIT,
    addChain => 5,
    editChain => 6,
    removeChain => 7,
    clearDb => 8,
    plugins => 9,
    help => 10,
    about => 11,
);

my $modelForInit;

sub new {
    my ($class, $amodel, $anewModelFn) = @_;
    $modelForInit = $amodel; # XXX OnInit is a method and not an asynchronous event *rolls eyes*
    my $self = $class->SUPER::new();
    $modelForInit = undef; # XXX
    $self->{model} = $amodel;
    $self->{newmodel} = $anewModelFn;
    return bless $self, $class;
}

sub OnInit {
    my $self = shift;

    my $frame = wxPerl::Frame->new(undef, 'Peele',
            style => &Wx::wxDEFAULT_FRAME_STYLE | &Wx::wxRESIZE_BORDER
            );

    my $chainList = UI::Components::ListEditor->new(
        $frame,
        'Chains',
        $modelForInit->{chains},
        sub {
            ...
        },
        sub {
            ...
        },
        sub {
            ...
        },
    );

    my $fileMenu = Wx::Menu->new();
    $fileMenu->Append($menuIds{newm}, "\&New");
    EVT_MENU($self, $menuIds{newm}, sub {
        &{ $self->{newmodel} }();
        $chainList->Clear();
        print "after";
    });
    $fileMenu->Append($menuIds{open}, "\&Open...");
    $fileMenu->Append($menuIds{save}, "\&Save As...");
    $fileMenu->AppendSeparator();
    $fileMenu->Append($menuIds{run}, "\&Run");
    $fileMenu->Append($menuIds{results}, "\&View Results...");
    $fileMenu->AppendSeparator();
    $fileMenu->Append($menuIds{exit}, "E\&xit");
    EVT_MENU($self, $menuIds{exit}, sub {$_[0]->Close(1)});

    my $editMenu  = Wx::Menu->new();
    $editMenu->Append($menuIds{addChain}, "\&Add Chain...");
    $editMenu->Append($menuIds{editChain}, "\&Edit Chain...");
    $editMenu->Append($menuIds{removeChain}, "\&Remove Chain");
    $editMenu->AppendSeparator();
    $editMenu->Append($menuIds{clearDb}, "Clear Database");
    $editMenu->AppendSeparator();
    $editMenu->Append($menuIds{plugins}, "Plugins \&Settings...");

    my $helpMenu  = Wx::Menu->new();
    $helpMenu->Append($menuIds{help}, "\&Help");
    $helpMenu->Append($menuIds{about}, "\&About");

    my $menubar = Wx::MenuBar->new();
    $menubar->Append($fileMenu, "\&File");
    $menubar->Append($editMenu, "\&Edit");
    $menubar->Append($helpMenu, "\&Help");

    $frame->SetMenuBar($menubar);
    $frame->SetSizer($chainList); # only one component
    $frame->SetAutoLayout(1);
    $frame->Show;
}

1;

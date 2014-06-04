package UI::PeeleApplication;

use Wx;
use wxPerl::Constructors;
use Wx::Event qw/EVT_MENU/;
use Wx::Menu;

use UI::Components::ListEditor;
use UI::PluginSettings;
use UI::HelpAbout;
use UI::ChainEditor;
use UI::ResultsDisplay;
use Core::DBEngine;

use warnings;
use strict;
use base 'Wx::App';

our @ISA = qw/Wx::App/;

our %menuIds = (
    newm        => 0,
    open        => 1,
    save        => 2,
    run         => 3,
    results     => 4,
    exit        => &Wx::wxID_EXIT,
    addChain    => 5,
    editChain   => 6,
    removeChain => 7,
    clearDb     => 8,
    plugins     => 9,
    help        => 10,
    about       => &Wx::wxID_ABOUT,
);

my $modelForInit;

sub new {
    my ( $class, $amodel, $anewModelFn, $saveModelFn ) = @_;
    $modelForInit = $amodel
      ;    # XXX OnInit is a method and not an asynchronous event *rolls eyes*
    my $self = $class->SUPER::new();
    $modelForInit = undef;      # XXX
    $self->{model} = $amodel;
    return bless $self, $class;
}

sub OnInit {
    my $self = shift;

    my $frame =
      wxPerl::Frame->new( undef, 'Peele',
        style => &Wx::wxDEFAULT_FRAME_STYLE | &Wx::wxRESIZE_BORDER );

    my @prettyChains = ();
    foreach ( @{ $modelForInit->{chains} } ) {
        push @prettyChains, UI::ChainEditor::to_nice_string($_);
    }
    my $chainList = UI::Components::ListEditor->new(
        $frame, 'Chains',
        \@prettyChains,
        sub {
            my $leChain = [];
            push $self->{model}->{chains}, $leChain;
            return $self->edit_chain($leChain);
        },
        sub {
            my ($idx) = @_;
            my $chain = @{ $self->{model}->{chains} }[$idx];
            return $self->edit_chain($chain);
        },
        sub {
            return (
                Wx::MessageBox( "Are you sure you want to delete this element?",
                    'Confirm', &Wx::wxYES_NO, $frame ) == &Wx::wxYES
            );
        }
    );

    my $fileMenu = Wx::Menu->new();
    $fileMenu->Append( $menuIds{newm}, "\&New" );
    EVT_MENU(
        $self,
        $menuIds{newm},
        sub {
            $self->{model}->load();
            $chainList->Clear();
            print "after";
        }
    );
    $fileMenu->Append( $menuIds{open}, "\&Open..." );
    EVT_MENU(
        $self,
        $menuIds{open},
        sub {
            # show file dialog
            my $fd = Wx::FileDialog->new(
                undef, 'Open...',, '', '',
                'Json data (*.json)|*.json|All files (*.*)|*.*',
                &Wx::wxFD_OPEN | &Wx::wxFD_FILE_MUST_EXIST
            );
            if ( $fd->ShowModal() == &Wx::wxID_CANCEL ) {
                $fd->Destroy();
            }

            # do saving
            my $path = $fd->GetPath();
            $fd->Destroy();
            $self->{model}->load($path);

            # refresh list view
            my $lb = $chainList->GetLB();
            $lb->Clear();
            foreach ( @{ $self->{model}->{chains} } ) {
                $lb->Append( UI::ChainEditor::to_nice_string($_) );
            }
            foreach ( @{ $self->{model}->{pluginPath} } ) {
                Core::PluginManager::load($_);
            }
        }
    );
    $fileMenu->Append( $menuIds{save}, "\&Save As..." );
    EVT_MENU(
        $self,
        $menuIds{save},
        sub {
            # show file dialog
            my $fd = Wx::FileDialog->new(
                undef, 'Save As...',, '', '',
                'Json data (*.json)|*.json',
                &Wx::wxFD_SAVE | &Wx::wxFD_OVERWRITE_PROMPT
            );
            if ( $fd->ShowModal() == &Wx::wxID_CANCEL ) {
                $fd->Destroy();
            }

            # do saving
            my $path = $fd->GetPath();
            $fd->Destroy();
            $self->{model}->save($path);
        }
    );
    $fileMenu->AppendSeparator();
    $fileMenu->Append( $menuIds{run}, "\&Run" );
    EVT_MENU(
        $self,
        $menuIds{run},
        sub {
            ...;
        }
    );
    $fileMenu->Append( $menuIds{results}, "\&View Results..." );
    EVT_MENU(
        $self,
        $menuIds{results},
        sub {
            if ( !defined
                $Core::PluginManager::dplugins{ $self->{model}->{dbCfg}->{plugin} } )
            {
                Wx::MessageBox(
        'Database Engine is not properly configured. Review your settings in Edit/Plugin Settings...',
                    'Error'
                );
                return;
            }
            my $db = Core::DBEngine->new( $self->{model}->{dbCfg} );
            my $rd = UI::ResultsDisplay->new( $db );
            $rd->ShowModal();
            $rd->Destroy();
        }
    );
    $fileMenu->AppendSeparator();
    $fileMenu->Append( $menuIds{exit}, "E\&xit" );
    EVT_MENU( $self, $menuIds{exit}, sub { $frame->Close(1) } );

    my $editMenu = Wx::Menu->new();
    $editMenu->Append( $menuIds{addChain}, "\&Add Chain..." );
    EVT_MENU(
        $self,
        $menuIds{addChain},
        sub {
            my $event = Wx::CommandEvent->new(&Wx::wxEVT_COMMAND_BUTTON_CLICKED, $chainList->GetAddBtn()->GetId());
            Wx::PostEvent($frame, $event);
        }
    );
    $editMenu->Append( $menuIds{editChain}, "\&Edit Chain..." );
    EVT_MENU(
        $self,
        $menuIds{editChain},
        sub {
            my $event = Wx::CommandEvent->new(&Wx::wxEVT_COMMAND_BUTTON_CLICKED, $chainList->GetEditBtn()->GetId());
            Wx::PostEvent($frame, $event);
        }
    );
    $editMenu->Append( $menuIds{removeChain}, "\&Remove Chain" );
    EVT_MENU(
        $self,
        $menuIds{removeChain},
        sub {
            my $event = Wx::CommandEvent->new(&Wx::wxEVT_COMMAND_BUTTON_CLICKED, $chainList->GetDelBtn()->GetId());
            Wx::PostEvent($frame, $event);
        }
    );
    $editMenu->AppendSeparator();
    $editMenu->Append( $menuIds{clearDb}, "Clear Database" );
    EVT_MENU(
        $self,
        $menuIds{clearDb},
        sub {
            if ( !defined
                $Core::PluginManager::dplugins{ $self->{model}->{dbCfg}->{plugin} } )
            {
                Wx::MessageBox(
        'Database Engine is not properly configured. Review your settings in Edit/Plugin Settings...',
                    'Error'
                );
                return;
            }
            if(Wx::MessageBox( "Are you sure you want to delete all contents of the database? The operation cannot be undone.",
                    'Confirm', &Wx::wxYES_NO, $frame ) == &Wx::wxYES)
            {
                my $db = Core::DBEngine->new( $self->{model}->{dbCfg} );
                my @vars = @{ $db->get_all() };
                foreach (@vars) {
                    $db->set($_, undef);
                }
            }
        }
    );
    $editMenu->AppendSeparator();
    $editMenu->Append( $menuIds{plugins}, "Plugins \&Settings..." );
    EVT_MENU(
        $self,
        $menuIds{plugins},
        sub {
            my $dlg = UI::PluginSettings->new( $self, $self->{model} );
            $dlg->ShowModal();
            $dlg->Destroy();
        }
    );

    my $helpMenu = Wx::Menu->new();
    $helpMenu->Append( $menuIds{help}, "\&Help" );
    EVT_MENU(
        $self,
        $menuIds{help},
        sub {
            UI::HelpAbout::ShowHelp();
        }
    );
    $helpMenu->Append( $menuIds{about}, "\&About" );
    EVT_MENU(
        $self,
        $menuIds{about},
        sub {
            UI::HelpAbout::ShowAbout();
        }
    );

    my $menubar = Wx::MenuBar->new();
    $menubar->Append( $fileMenu, "\&File" );
    $menubar->Append( $editMenu, "\&Edit" );
    $menubar->Append( $helpMenu, "\&Help" );

    $frame->SetMenuBar($menubar);
    $frame->SetSizer($chainList);    # only one component
    $frame->SetAutoLayout(1);
    $frame->Show;
}

sub edit_chain {
    my ( $self, $leChain ) = @_;
    if ( !defined
        $Core::PluginManager::dplugins{ $self->{model}->{dbCfg}->{plugin} } )
    {
        Wx::MessageBox(
'Database Engine is not properly configured. Review your settings in Edit/Plugin Settings...',
            'Error'
        );
        return;
    }
    my $db = Core::DBEngine->new( $self->{model}->{dbCfg} );
    my $chainEd = UI::ChainEditor->new( $leChain, $db );
    $chainEd->ShowModal();
    $chainEd->Destroy();
    return UI::ChainEditor::to_nice_string($leChain);
}

1;

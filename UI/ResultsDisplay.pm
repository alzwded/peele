package UI::ResultsDisplay;

use Wx;
use Wx::SimplePlotter;

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
    my ($class, $db) = @_;
    my $self = $class->SUPER::new(undef, -1, 'Chain', &Wx::wxDefaultPosition, [400, 400], &Wx::wxDEFAULT_DIALOG_STYLE|&Wx::wxRESIZE_BORDER);

    my $sb = Wx::ScrolledWindow->new($self, -1, &Wx::wxDefaultPosition, &Wx::wxDefaultSize, &Wx::wxVSCROLL);

    my $sizer = Wx::BoxSizer->new( &Wx::wxVERTICAL );

    # get variables
    my @vars = @{ $db->get_all() };

    # plot them
    foreach (@vars) {
        my $varName = $_;
        # but first get the actual value
        my $varData = $db->get($varName);

        my $plottedVariable = plot_variable($varName, $varData, $sb, $sizer);
        $sizer->Add($plottedVariable, 0, &Wx::wxEXPAND);
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

sub plot_variable {
    my ($varName, $varData, $sb, $sizer) = @_;

    if($varData->{type} eq 'field') {
        my $fieldSizer = Wx::BoxSizer->new( &Wx::wxHORIZONTAL );

        my $label = Wx::StaticText->new($sb, -1, $varName);
        $fieldSizer->Add($label, 1, &Wx::wxEXPAND);

        my $value = Wx::StaticText->new($sb, -1, $varData->{value});
        $fieldSizer->Add($value, 1, &Wx::wxEXPAND);

        return $fieldSizer;
    } elsif($varData->{type} eq 'array') {
        my $staticBoxSizer = Wx::StaticBoxSizer->new(
                Wx::StaticBox->new($sb, -1, $varName),
                &Wx::wxHORIZONTAL);
        my $plotWidget = Wx::SimplePlotter->new($sb, -1, &Wx::wxDefaultPosition, [-1, 175]);
        $plotWidget->SetColours([0, 255, 0]);

        my $idx = 0;
        my @points = map { [$idx++, $_] } @{ $varData->{value} };

        $plotWidget->SetBackgroundColour(Wx::Colour->new(0, 0, 0));
        $plotWidget->SetPoints(\@points);
        $staticBoxSizer->Add($plotWidget, 1, &Wx::wxEXPAND);

        return $staticBoxSizer;
    } elsif($varData->{type} eq 'wave') {
        my $staticBoxSizer = Wx::StaticBoxSizer->new(
                Wx::StaticBox->new($sb, -1, $varName),
                &Wx::wxVERTICAL);
        my $plotWidget = Wx::SimplePlotter->new($sb, -1, &Wx::wxDefaultPosition, [-1, 175]);

        my @colours = ();
        my @plots = ();

        foreach (keys %{ $varData->{value} }) {
            my $key = $_;
            my $color = get_random_color();
            push @colours, $color;

            my $idx = 0;
            my @points = map { [$idx++, $_] } @{ $varData->{value}->{$key} };
            push @plots, \@points;

            # not all label controls are created equal...
            my $panel = Wx::Panel->new($sb, -1);
            my $panelSizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);

            $panel->SetBackgroundColour(Wx::Colour->new(@{ $color })); # so create a panel that has a background

            my $legendary = Wx::StaticText->new($panel, -1, $key);
            $legendary->SetForegroundColour(Wx::Colour->new(@{ complementary($color) }));

            $panelSizer->Add($legendary, 1, &Wx::wxEXPAND);
            $panel->SetSizer($panelSizer);
            $panel->SetAutoLayout(1);
            $staticBoxSizer->Add($panel, 0, &Wx::wxEXPAND);
        }

        $plotWidget->SetBackgroundColour(Wx::Colour->new(0, 0, 0));
        $plotWidget->SetColours(@colours);
        $plotWidget->SetPoints(@plots);
        $staticBoxSizer->Add($plotWidget, 1, &Wx::wxEXPAND);

        return $staticBoxSizer;
    } elsif($varData->{type} eq 'lambda') {
        return plot_variable($varName, $varData->{value}->{return}, $sb, $sizer);
    } else {
        die "Invalid type: $varData->{type}; check the database for consistency";
    }
}

sub get_random_color {
    return [128 + int rand 127, 128 + int rand 127, 128 + int rand 127];
}

sub complementary {
    my ($r, $g, $b) = @{ $_[0] };
    return [255 - $r, 255 - $g, 255 - $b];
}

1;

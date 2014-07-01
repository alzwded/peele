#!/usr/bin/perl -w

use strict;

my $data = {
    R1_1 => ["IFruit 10 0", "IGod 10 0", "Shop 10 10 IGod",
        "Bascket 10 10 IGod", "Apple 10 10 IFruit", "Pear 10 10 IFruit"],
    R1_2 => ["IFruit 5 0", "IGod 10 0", "ITraits 3 0", "ICustom 2 0",
        "Bascket 10 10 IGod", "Shop 10 10 IGod",
        "Apple 5 10 IFruit", "Pear 5 10 IFruit",
        "AppleTraits 3 5 ITraits", "PearTraits 2 5 ITraits",
        "BascketCustom 2 5 ICustom", "ShopCustom 2 5 ICustom"],
    R1_3 => ["IFruit 5 0", "IGod 10 0", "ITraits 5 0", "ICustom 5 0",
        "Bascket 10 5 IGod", "Shop 10 5 IGod",
        "Apple 5 5 IFruit", "Pear 5 5 IFruit",
        "AppleTraits 5 2 ITraits", "PearTraits 5 2 ITraits",
        "BascketCustom 5 0 ICustom", "ShopCustom 2 0 ICustom",
        "Orange 5 5 IFruit", "Bologna 5 5 IFruit",
        "OrangeTraits 5 2 ITraits", "BolognaTraits 5 2 ITraits"],
    R2_1 => ["IFirst 3 0", "ISecond 3 0", "IThird 3 0", "ThirdA 4 1 IThird",
        "ThirdB 4 1 IThird", "ThirdC 5 2 IThird",
        "FirstDerA 3 2 IFirst", "FirstDerB 3 2 IFirst",
        "SecondDerA 3 2 ISecond", "SecondDerB 3 2 ISecond",
        "ThirdADerA 4 3 ThirdA", "ThirdADerB 4 3 ThirdA",
        "ThirdBDerA 4 3 ThirdA", "ThirdBDerB 4 3 ThirdB",
        "ThirdCDerA 5 3 ThirdC", "ThirdCDerB 5 3 ThirdC"],
};

my $prs = {
    R1_1 => "16 16 8 16 12 16 16 12 16 12",
    R1_2 => "16 16 8 16 12 16 16 12 16 12",
    R1_3 => "16 16 8 16 12 16 16",
    R2_1 => "16 12 8 12 12 16 16 12 16 12",
};

foreach my $i (1..4) {
    foreach my $j (1..3) {
        my $rev = "R${i}_${j}";
        last if !defined $data->{$rev};
        foreach my $file (@{ $data->{$rev} }) {
            system("cd $rev && ../buildFile.pl $file");
        }
        system("cd PRs && ../buildPRs.pl $rev $prs->{$rev}");
    }
}

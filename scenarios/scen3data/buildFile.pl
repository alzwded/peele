#!/usr/bin/perl -w

use strict;

my @types = ("int", "char*", "void*", "float", "Thing&", "Thing const&", "Accumulator&", "string", "int const&", "float*", "double**", "void", "void");

srand();

my ($name, $nvirt, $nstat, $parent) = @ARGV;

die unless defined($name) && defined($nvirt) && defined($nstat);

my $guard = (uc $name)."_HXX";

open A, ">$name.hxx";

print A <<EOT;
#ifndef $guard
#define $guard

EOT

print A <<EOT if defined $parent;
#include "$parent.hxx"

EOT

print A <<EOT;
class $name
EOT

if(defined $parent) {
    print A ": public $parent\n";
}

print A "{\npublic:\n";

foreach ( 1..$nvirt ) {
    my ($r1, $r2) = (int(rand scalar @types), int(rand scalar @types));
    print A "    virtual $types[$r1] v$_($types[$r2]);\n";
}

print A "\n";

foreach ( 1..$nstat ) {
    my ($r1, $r2) = (int rand scalar @types, int rand scalar @types);
    print A "    $types[$r1] m$_($types[$r2]);\n";
}

my $r1 = int rand scalar @types;
print A "\n";
print A "    $name();\n" unless $nstat > 2 or $nvirt > 2;
print A "    $name($types[$r1]);\n" unless $nstat == 0;
print A "    virtual ~$name();\n" unless $nvirt == 0 && !defined($parent);

print A <<EOT;
};

#endif
EOT

close A;

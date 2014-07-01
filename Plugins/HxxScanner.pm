package HxxScanner;

use strict;
use warnings;

use File::Spec;
use Cwd;

my $verbose = undef;

sub new {
    my ($class, $cfg) = @_;
    my $self = {};
    return bless $self, $class;
}

sub apply {
    my ($self, $x) = @_;
    if($x->{type} eq 'array') {
        my @files = @{ $x->{value} };
        unless(scalar @files > 0) {
            return {
                type => 'array',
                value => [],
            };
        }

        # grab first file, get repo root
        my $first = $files[0];
        my $rootDir = get_root_tree($first);
        unless(defined $rootDir) {
            print "not in a git repository!\n";
            return undef;
        }

        print "git repo root is: $rootDir\n";

        my @commits = parse_revision_log($rootDir);

        my $data = accumulate_data($rootDir, \@commits, \@files);
    
        return {
            type => 'wave',
            value => $data,
        }
    } elsif($x->{type} eq 'field') {
        my $ary = {
            type => 'array',
            value => [$x],
        };
        return $self->apply($ary);
    } else {
        return {
            type => 'array',
            value => [],
        }
    }
}

sub default_parameters {
    return {};
}

sub get_root_tree {
    my ($file) = @_;

    $file = Cwd::realpath($file);

    my ($volume, $dirs, $filename) = File::Spec->splitpath($file, 0);

    if(-d $file) {
        return find_root_tree_rec(File::Spec->catdir(($volume, $dirs, $filename)));
    } else {
        return find_root_tree_rec(File::Spec->catdir(($volume, $dirs)));
    }
}

sub find_root_tree_rec {
    my ($dir) = @_;
    use Data::Dumper;

    if(!defined($dir) || $dir eq '') {
        return undef;
    }

    print "      $dir\n" if defined $verbose;

    if(-d File::Spec->catdir(($dir, ".git"))) {
        return File::Spec->canonpath($dir);
    }

    my $nextDir = Cwd::realpath(
        File::Spec->canonpath(
            File::Spec->catdir(
                ($dir, File::Spec->updir())
                )
            )
        );

    return find_root_tree_rec($nextDir);
}

sub parse_revision_log {
    my ($dir) = @_;

    my $cmd = "git --work-tree=\"$dir\" --git-dir=\"".(File::Spec->catdir($dir, ".git"))."\" log";
    my $s = `$cmd`;
    if($? != 0) {
        print "git log failed\n";
        return undef;
    }

    my @lines = reverse split /\n/, $s;

    my @commits = ();

    foreach (@lines) {
        if($_ =~ m/^commit ([a-f0-9]*)$/) {
            push @commits, $1;
        }
    }

    return @commits;
}

sub accumulate_data {
    my ($dir, $commits, $files) = @_;
    #my %hsh = map { ($_ => []) } @{ $files };
    my $result = {
        hdepth => [],
        nsiblings => [],
        dsiblings => [],
        nvirt => [],
    };

    my $gitcmd = "git --work-tree=\"$dir\" --git-dir=\"".(File::Spec->catdir($dir, ".git"))."\" cat-file -p ";

    foreach (@{ $commits }) {
        my $commit = $_;
        print "parsing commit $commit\n";
        my ($firstLine) = split /\n/, `$gitcmd $commit`;
        if($? != 0) {
            print "git cat-file failed, 129\n";
            return undef;
        }
        $firstLine =~ m/^tree ([a-f0-9]*)$/;
        my $tree = $1;

        print "  tree is: $tree\n" if defined $verbose;

        my $dahash = {
            inher => {},
            nvirt => {},
            nmeth => {},
        };

        parse_tree_rec($tree, $dir, $gitcmd, $dahash, $files);

        my %stats = %{ compute_stats($dahash) };

        foreach (keys %stats) {
            push @{ $result->{$_} }, $stats{$_};
        }
    }

    return $result;
}

sub parse_tree_rec {
    my ($tree, $dir, $gitcmd, $dahash, $files) = @_;

    print "  at tree $tree in dir $dir\n" if defined $verbose;

    print "$gitcmd $tree\n" if defined $verbose;
    my @lines = split /\n/, `$gitcmd $tree`;
    if($? != 0) {
        print "git cat-file failed 151\n";
        return undef;
    }

    foreach (@lines) {
        $_ =~ m/^[^ ]* ([^ ]*) ([^ \t]*)\s*(.*)$/;
        my ($type, $sha, $filename) = ($1, $2, $3);
        print "    type=$type;sha=$sha;filename=$filename\n" if defined $verbose;

        if($type eq 'tree') {
            parse_tree_rec($sha, "$dir/$filename", $gitcmd, $dahash, $files);
            next;
        }

        my $leSame = sub {
            my ($path, $pat) = @_;
            $pat = quotemeta $pat;
            if($path =~ m/.*$pat.*/) { return 1 }
            return 0;
        };
        if(grep { &{ $leSame }(Cwd::realpath("$dir/$filename"), Cwd::realpath($_)) } @{ $files }) {
            my $lines = `$gitcmd $sha`;
            if($? != 0) {
                print "git cat-file failed, last instance\n";
                return undef;
            }

            parse_file($lines, $dahash);
        }
    }
}

sub compute_stats {
    my ($dahash) = @_;
    my $ret = {};

    my ($sum, $count) = (0.0, 0.0);
    use Data::Dumper;
    print '*' x 20 . "\n" if defined $verbose;
    print Dumper $dahash if defined $verbose;
    print '*' x 20 . "\n" if defined $verbose;
    foreach (keys %{ $dahash->{nvirt} }) {
        $sum += $dahash->{nvirt}->{$_};
        $count++;
    }
    $ret->{nvirt} = $sum / $count;

    # build inheritance tree

    # compute mean hdepth
    $sum = 0;
    print "inher<<\n" if defined $verbose;
    foreach (%{ $dahash->{inher} }) {
        my $current = $_;
        my $h = 0;
        while(defined $dahash->{inher}->{$current} && $dahash->{inher}->{$current} ne ''
        ) {
            print " "x$h . ":$current<-" . $dahash->{inher}->{$current} . "\n" if defined $verbose;
            ++$h;
            $current = $dahash->{inher}->{$current};
        }
        $sum += $h;
    }
    $ret->{hdepth} = $sum / $count;

    # build map of class -> siblings
    # compute delta
    # compute mean delta
    use Data::Dumper;
    print Dumper $dahash if defined $verbose;
    my ($nsiblingssum, $ndeltasum) = (0, 0);
    foreach (keys %{ $dahash->{inher} }) {
        my $key = $_;
        print "  $key\n" if defined $verbose;
        my @siblings = grep { $dahash->{inher}->{$key} eq $dahash->{inher}->{$_} } keys %{ $dahash->{inher} };
        $nsiblingssum += scalar @siblings;

        # compute delta
        my $smallSum = 0;
        my $my = $dahash->{nmeth}->{$key} - $dahash->{nvirt}->{$key};
        foreach (@siblings) {
            my $his = $dahash->{nmeth}->{$_} - $dahash->{nvirt}->{$_};
            $smallSum += $my + $his;
            print "<delta $his $my> $smallSum " if defined $verbose;
        }
        print Dumper @siblings if defined $verbose;
        my $delta = $smallSum / scalar(@siblings);
        $ndeltasum += $delta;
    }

    $ret->{nsiblings} = $nsiblingssum / $count;
    $ret->{dsiblings} = $ndeltasum / $count;

    return $ret;
}

sub parse_file {
    my ($lines, $dahash) = @_;

    # whatever you do, do not run this parser on a production C++ header, it will fail miserably
    # you can/cannot parse the following
    #   single inheritance classes
    #   classes that do not inherit from anywhere
    #   forward declarations are correctly ignored
    #   out-of-class function/method definitions are correctly ignored
    #   inner classes are not counted correctly
    #   do not use namespaces
    #   do not have comments in bad places that contain unfortunate characteres/keywords like: {, class, ;, entire method declarations, etc
    # if you need to parse C++ nicely, go grab the reference BNF grammar, add actions to the rules and compile that one

    my @chars = split //, $lines;

    my $Rclass = '';
    my $Rparent = '';
    my $Rparen = 0;
    my $state = 'initial';
    while(scalar @chars) {
        if($state eq 'initial') {
            print "  PARSE: in state initial\n" if defined $verbose;
            last if(scalar @chars < 5);

            if(join('' => @chars[0..4]) eq 'class') {
                splice @chars, 0, 5;

                (join '' => @chars) =~ m/^(\s+)([a-zA-Z0-9_]+)/;
                my $whiteSpace = $1;
                $Rclass = $2;
                splice @chars, 0, (length($whiteSpace) + length($Rclass));
                $state = 'inheritance?';

                print "found class: $Rclass\n";
            } else {
                shift @chars;
            }
        } elsif($state eq 'inheritance?') {
            print "  PARSE: in state inheritance?\n" if defined $verbose;
            if(join('' => @chars) =~ m/^(\s*:\s*)(public|protected|private)\s+([a-zA-Z0-9_]+)/) {
                my $ws = $1;
                $Rparent = $3;
                splice @chars, 0, (length($ws) + length($Rparent));

                $dahash->{inher}->{$Rclass} = $Rparent;
                print "  PARSE: in inheritance: base $Rclass parent $Rparent\n" if defined $verbose;
                unless(defined $dahash->{inher}->{$Rparent}) {
                    $dahash->{inher}->{$Rparent} = '';
                    print "  PARSE: in inheritance: overwritiing $Rparent\n" if defined $verbose;
                }
                $dahash->{nvirt}->{$Rclass} = 0;
                $dahash->{nmeth}->{$Rclass} = 0;

                while($chars[0] ne '{') { shift @chars; }
                shift @chars;
                $state = 'inclass';
            } elsif(join('' => @chars) =~ m/^(\s*;)/) {
                splice @chars, 0, (length($1));
                $state = 'initial';
            } elsif(join('' => @chars) =~ m/^(\s*[{])/) {
                $dahash->{inher}->{$Rclass} = '';
                $dahash->{nvirt}->{$Rclass} = 0;
                $dahash->{nmeth}->{$Rclass} = 0;
                $state = 'inclass';
                splice @chars, 0, (length($1));
            } else {
                $state = 'initial';
            }
        } elsif($state eq 'inclass') {
            print "  PARSE: in state inclass\n" if defined $verbose;
            #if(join('' => @chars) =~ m/^(\s*virtual\s+[^{;]*)/) {
            if(join('' => @chars) =~ m/^(\s*virtual\s+)([a-zA-Z_0-9*&~<>\-&^|+\/=! \t\n]+\([^)]*\))/) {
                $dahash->{nvirt}->{$Rclass}++;
                $dahash->{nmeth}->{$Rclass}++;
                splice @chars, 0, (length($1) + length($2));
                #if(substr($1, length($1) - 1) eq '{') {
                #    $state = 'inmethod';
                #}
                print "$2\n" if defined $verbose;
                next;
            } elsif(join('' => @chars) =~ m/^(\s*friend\s+[^;]+)/) {
                splice @chars, 0, length($1);
                next;
            } elsif(join('' => @chars) =~ m/^(\s*[a-zA-Z_0-9*&~<>\-+\/=!|^]+\([^)]*\))/) {
                print "$1\n" if defined $verbose;
                $dahash->{nmeth}->{$Rclass}++;
                splice @chars, 0, length($1);

                if(join('' => @chars) =~ m/^(\s*[:])/) {
                    if(join('' => @chars) =~ m/^([^;{]*)/) {
                        splice @chars, 0, length($1);
                    }
                }

                next;
            }

            my $char = shift @chars;
            if($char eq '{') {
                $state = 'inmethod';
                next;
            } elsif($char eq '}') {
                $state = 'initial';
                next;
            }
        } elsif($state eq 'inmethod') {
            print "  PARSE: in state inmethod\n" if defined $verbose;
            my $char = shift @chars;
            if($char eq '{') {
                ++$Rparen;
            } elsif($char eq '}') {
                if($Rparen == 0) {
                    $state = 'inclass';
                    next;
                } else {
                    --$Rparen;
                }
            }
        }
    }
}

1;

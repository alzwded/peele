package HxxScanner;

use strict;
use warnings;

use File::Spec;
use Cwd;

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

    my ($volume, $dirs, $filename) = File::Spec->splitpath($file, 0);

    return find_root_tree_rec(File::Spec->catdir(($volume, $dirs)));
}

sub find_root_tree_rec {
    my ($dir) = @_;
    use Data::Dumper;

    if(!defined($dir) || $dir eq '') {
        return undef;
    }

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

    $dir = quotemeta $dir;
    my $s = `git --work-tree=$dir --git-dir=$dir/.git log`;
    if($? != 0) {
        print "git log failed\n";
        return undef;
    }

    my @lines = split /\n/, $s;

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
    my %hsh = map { ($_ => []) } @{ $files };
    my $dahash = \%hsh;

    my $gitdir = quotemeta $dir;
    my $gitcmd = "git --work-tree=$gitdir --git-dir=$gitdir/.git cat-file -p ";

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

        print "  tree is: $tree\n";

        foreach my $key (keys %{ $dahash }) {
            print "key: $key\n";
            push @{ $dahash->{$key} }, '';
        }
        parse_tree_rec($tree, $dir, $gitcmd, $dahash, $files);
    }

    return $dahash;
}

sub parse_tree_rec {
    my ($tree, $dir, $gitcmd, $dahash, $files) = @_;

    print "  at tree $tree in dir $dir\n";

    print "$gitcmd $tree\n";
    my @lines = split /\n/, `$gitcmd $tree`;
    if($? != 0) {
        print "git cat-file failed 151\n";
        return undef;
    }

    foreach (@lines) {
        $_ =~ m/^[^ ]* ([^ ]*) ([^ \t]*)\s*(.*)$/;
        my ($type, $sha, $filename) = ($1, $2, $3);
        print "    type=$type;sha=$sha;filename=$filename\n";

        if($type eq 'tree') {
            parse_tree_rec($sha, "$dir/$filename", $gitcmd, $dahash, $files);
            next;
        }

        if(grep { File::Spec->canonpath("$dir/$filename") eq File::Spec->canonpath($_) } @{ $files }) {
            print "    found match for $dir/$filename\n";
            my $fdata = `$gitcmd $sha`;
            if($? != 0) {
                print "git cat-file failed, last instance\n";
                return undef;
            }
            @{ $dahash->{"$dir/$filename"} }
                [ scalar @{ $dahash->{"$dir/$filename"} }
                    - 1
                    ]
                = $fdata;
        }
    }
}

1;

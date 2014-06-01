package PluginManager;

our @fplugins = ();
our @dplugins = ();

sub load {
    my ($path) = @_;
    if(not -d $path) {
        print "'$path' not a directory\n";
        return;
    }
    $path =~ s#/$##;
    my @files = gather_modules($path);

    foreach (@files) {
        my $file = $_;
        eval {
            require $file;
            my $quotedPath = quotemeta $path;
            $file =~ s#^$quotedPath/(.*)\.pm$#$1#;
            $file =~ s#/#::#g;
        };
        if($@) {
            print "can't load $file: $@\n";
            next;
        }
        my $eah = which_interface($file);
        if(!$eah) {
            print "incompatible interface for $file\n";
            next;
        } elsif($eah == 1) {
            push @fplugins, $file;
        } elsif($eah == 2) {
            push @dplugins, $file;
        }
    }
}

sub gather_modules {
    my ($path) = @_;
    $path =~ s#/$##;

    opendir A, $path;
    my @all = readdir A;
    my @files = map { $path."/".$_ ; } grep { $_ =~ m/^.*\.pm$/ ; } grep { -f "$path/$_" ; } @all;
    my @dirs = grep { -d "$path/$_" } grep { $_ !~ m/^\..*$/ } @all;
    closedir A;

    foreach (@dirs) {
        push @files, gather_modules($path."/".$_);
    }

    return @files;
}

sub which_interface {
    my ($file) = @_;
    my $modname = $file."\::";

    # check for a computational interface
    if(
        defined $modname->{new} and
        defined $modname->{apply} and
        defined $modname->{default_parameters})
    { return 1; }

    # check for a DB interface
    if(
        defined $modname->{configure} and
        defined $modname->{open} and
        defined $modname->{close} and
        defined $modname->{default_parameters})
    { return 2; }
    return 0;
}

1;

package Core::PluginManager;

our %fplugins = ();
our %dplugins = ();

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
            $fplugins{$file} = 1;
        } elsif($eah == 2) {
            $dplugins{$file} = 1;
        } else {
            print "unexpected return value from which_interface: $eah\n";
        }
    }
}

sub gather_modules {
    my ($path) = @_;
    $path =~ s#/$##;

    opendir A, $path;
    my @all = readdir A;
    my @files = grep { $_ =~ m/^.*\.pm$/ ; } grep { -f "$_" ; } map { "$path/$_" ; } @all;
    my @dirs = grep { -d $_ } map { "$path/$_" } grep { $_ !~ m/^\..*$/ } @all;
    closedir A;

    foreach (@dirs) {
        push @files, gather_modules($_);
    }

    return @files;
}

sub which_interface {
    my ($file) = @_;
    my $modname = $file."\::"; # this is a hash of the things contained in the module

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
        defined $modname->{default_parameters} and
        defined $modname->{query})
    { return 2; }
    return 0;
}

1;

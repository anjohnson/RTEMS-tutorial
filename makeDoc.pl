my $BINUTILS, $GCC, $NEWLIB;
my $GCCDIFF, $NEWLIBDIFF;
my $RTEMS_SOURCES_URL, $RTEMS_BINUTILS_URL, $RTEMS_GCC_URL, $RTEMS_NEWLIB_URL;

sub getParm {
    ($shellName) = @_;
    my $command, $val;
    $command="grep '^$shellName=' getAndBuildTools.sh";
    $val=`$command`;
    $val =~ s/\${RTEMS_VERSION}/\\rtemsVersion/;
    $val =~ s/\${RTEMS_BASE_VERSION}/\\rtemsBaseVersion/;
    $val =~ s/.*=//;
    $val =~ s/_/\\_/g;
    $val =~ s/[\n \t]*$//;
    return $val;
}

$RTEMS_SOURCES_URL = getParm("RTEMS_SOURCES_URL");
$BINUTILS          = getParm("BINUTILS");
$GCC               = getParm("GCC");
$NEWLIB            = getParm("NEWLIB");
$BINUTILSDIFF      = getParm("BINUTILSDIFF");
$GCCDIFF           = getParm("GCCDIFF");
$NEWLIBDIFF        = getParm("NEWLIBDIFF");
$RTEMS_VERSION     = getParm("RTEMS_VERSION");


print "\\newcommand{\\RTEMSSOURCEURL}{$RTEMS_SOURCES_URL}\n";
print "\\newcommand{\\BINUTILS}{$BINUTILS}\n";
print "\\newcommand{\\GCC}{$GCC}\n";
print "\\newcommand{\\NEWLIB}{$NEWLIB}\n";
print "\\newcommand{\\BINUTILSDIFF}{$BINUTILSDIFF}\n";
print "\\newcommand{\\GCCDIFF}{$GCCDIFF}\n";
print "\\newcommand{\\NEWLIBDIFF}{$NEWLIBDIFF}\n";
print "\\newcommand{\\rtemsVersion}{$RTEMS_VERSION}\n";
print "\\newcommand{\\rtemsBaseVersion}{$RTEMS_BASE_VERSION}\n";


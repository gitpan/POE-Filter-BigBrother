#!/usr/bin/perl -w
# $Id: 01_BigBrother.t yblusseau $
# vim: filetype=perl

# Exercises Filter::BigBrother without the rest of POE.
# Suddenly things are looking a lot easier.

use strict;
use lib qw(t);

use TestFilter;
use Test::More tests => 4 + $COUNT_FILTER_INTERFACE;

sub POE::Kernel::ASSERT_DEFAULT () { 1 }
sub POE::Kernel::TRACE_DEFAULT  () { 1 }
sub POE::Kernel::TRACE_FILENAME () { "./test-output.err" }

use_ok("POE::Filter::BigBrother");
test_filter_interface("POE::Filter::BigBrother");

my $msg1 = "status localhost,localdomain.disk red Tue Jun 17 15:49:12 CEST 2008 - Disk on localhost.localdomain at PANIC level";
my $msg2 = "status localhost,localdomain.cpu yellow Tue Jun 17 15:49:13 CEST 2008 - Cpu error on localhost.localdomain";

# Test filter One Message
{
  my $filter = new POE::Filter::BigBrother();
  my $raw    = $filter->put( [ $msg1 ] );

  my $cooked = $filter->get( $raw );
  is_deeply($cooked, [ $msg1 ], "get() only one message");
}

# Test filter Combo Message
{
  my $filter = new POE::Filter::BigBrother();

  my $raw    = $filter->put( [ "combo\n$msg1" ] );

  my $cooked = $filter->get( $raw );
  is_deeply($cooked, [ "$msg1" ], "get() only one message in a combo");

  $raw	  = $filter->put( [ "combo\n$msg1\n\n$msg2" ] );
  $cooked = $filter->get( $raw );

  is_deeply($cooked, [ "$msg1", "$msg2" ], "get() the two messages of a combo");
}

exit;

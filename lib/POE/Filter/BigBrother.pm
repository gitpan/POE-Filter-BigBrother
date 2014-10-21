# -*- encoding: utf-8; mode: cperl -*-

# $Id: BigBrother.pm yblusseau $

package POE::Filter::BigBrother;

use strict;
use warnings;
use POE::Filter;

use vars qw($VERSION @ISA);
$VERSION   = '0.11';
@ISA = qw(POE::Filter);

sub DEBUG () 	 { 0 }

sub BUFFER ()    { 0 }
sub COMBO_MSG () { 1 }

#------------------------------------------------------------------------------
sub new {
  my $type = shift;

  my $self = bless [
    '',           # BUFFER
	0 ,			  # COMBO_MSG
  ], $type;

  $self;
}


#------------------------------------------------------------------------------
# get() is inherited from POE::Filter.

#------------------------------------------------------------------------------
# 2001-07-27 RCC: The get_one() variant of get() allows Wheel::Xyz to
# retrieve one filtered block at a time.  This is necessary for filter
# changing and proper input flow control.

sub get_one_start {
  my ($self, $stream) = @_;
  $self->[BUFFER] .= join '', @$stream;

  DEBUG and warn $self->[BUFFER];

  # Is it a combo message ?
  if ($self->[BUFFER] =~ s/^combo(?:\x0D\x0A?|\x0A\x0D?)//) {
	  $self->[COMBO_MSG] = 1; # The message is a combo message
  }
}

sub get_one {
  my $self = shift;
  return [] unless length $self->[BUFFER];
  # Split the Combo message
  if ($self->[COMBO_MSG] &&
	  $self->[BUFFER] =~ m/(.*?) # the datas
						   (?:(?:\x0D\x0A?){2}|(?:\x0A\x0D?){2}) # two newline
						   (status.*) # start of the new status message
						  /xism) {
	  $self->[BUFFER] = $2; # Next message
	  return [ $1 ]; 		# Return the data
  } else {
	  my $block = $self->[BUFFER];
	  $self->[BUFFER] = ''; # Clear the buffer
	  return [ $block ];	# Return the data
  }
}

#------------------------------------------------------------------------------

sub put {
	my ($self, $chunks) = @_;
	[ @$chunks ];
}

#------------------------------------------------------------------------------

sub get_pending {
  my $self = shift;
  return undef unless length $self->[BUFFER];
  [ $self->[BUFFER] ];
}

1; # End of POE::Filter::BigBrother
__END__

=head1 NAME

POE::Filter::BigBrother - protocol abstractions for BigBrother streams

=head1 SYNOPSIS

To use with POE::Wheel classes, pass a POE::Filter object to one of
the /.*Filter$/ constructor parameters.

=head1 PUBLIC FILTER METHODS

Please see POE::Filter.

=head1 SEE ALSO

POE::Filter.

The SEE ALSO section in L<POE> contains a table of contents covering
the entire POE distribution.

=head1 AUTHOR

Yves Blusseau <yblusseau@cpan.org>

=head1 BUGS

None known.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc POE::Filter::BigBrother

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/POE-Filter-BigBrother>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/POE-Filter-BigBrother>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POE-Filter-BigBrother>

=item * Search CPAN

L<http://search.cpan.org/dist/POE-Filter-BigBrother>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Yves Blusseau. All rights reserved.

POE::Filter::BigBrother is free software; you may use, redistribute,
and/or modify it under the same terms as Perl itself.

=cut

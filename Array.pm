package JCMT::ACSIS::Array;

=head1 NAME

JCMT::ACSIS::Array - Array information for ACSIS

=head1 SYNOPSIS

 use JCMT::ACSIS::Array;

 my $array = new JCMT::ACSIS::Array( File => $file );

 my $receptor = $array->receptor( 3 );
 my @receptors = $array->receptor( 3, 6, 7 );
 my $pixel = $array->pixel( 'H03' );

=head1 DESCRIPTION

This class provides a simple interface between receptor name and pixel
position for ACSIS data.

=cut

use 5.006;
use strict;
use Carp;
use warnings;

use NDF;
use Starlink::HDSPACK qw/ retrieve_locs /;

use vars qw/ $VERSION /;

$VERSION = sprintf( "%d", q$Revision$ =~ /(\d+)/);

=head1 METHODS

=head2 Constructor

=over 4

=item B<new>

Create a new array object.

 $array = new JCMT::ACSIS::Array( File => $file );

Takes one named argument, the file from which the receptor/pixel
information is taken. If this argument is not given, an error is
thrown.

=cut

sub new {
  my $proto = shift;
  my $class = ref( $proto ) || $proto;

  # Read the arguments.
  my %args;
  if( $#_ % 2 ) {
    %args = @_;
  } else {
    croak "Must supply arguments in key => value pairs\n";
  }

  croak "Must supply File name to JCMT::ACSIS::Array constructor\n"
    unless exists $args{File};

  # Create the base Array.
  my $array = bless {
                     RECEPTORS => {},
                    }, $class;


  $array->_import_file( $args{File} );

  return $array;
}

=back

=head2 Accessors

=over 4

=item B<receptor>

Retrieve the receptor name for the given pixel.

 my $receptor = $array->receptor( 3 );
 my @receptors = $array->receptor( 3, 6, 7 );

This accessor takes a list of pixel positions. When called in scalar
context and only one pixel is given, then a scalar will be
returned. When called in scalar contact and more than one pixel is
given, then an array reference will be returned. When called in list
context, a list will be returned.

=cut

sub receptor {
  my $self = shift;
  my @pixels = @_;

  my @receptors = map { $self->_pixel_mapping->{$_} } @pixels;

  if( wantarray ) {
    return @receptors;
  } elsif( $#pixels == 0 ) {
    return $receptors[0];
  } else {
    return \@receptors;
  }
}

=item B<receptors>

Return a sorted list of all of the receptors in the array.

 @receptors = $array->receptors;

Takes no arguments.

=cut

sub receptors {
  my $self = shift;
  return sort keys %{$self->{RECEPTORS}};
}

=item B<pixel>

Retrieve the pixel for the given receptor name.

 my $pixel = $array->pixel( 'H03' );
 my @pixels = $array->pixel( 'H03', 'H09', 'H13' );

This accessor takes a list of receptors. When called in scalar context
and only one receptor is given, then a scalar will be returned. When
called in scalar contact and more than one receptor is given, then an
array reference will be returned. When called in list context, a list
will be returned.

=cut

sub pixel {
  my $self = shift;
  my @receptors = @_;

  my @pixels = map { $self->_receptor_mapping->{$_} } @receptors;

  if( wantarray ) {
    return @pixels;
  } elsif( $#receptors == 0 ) {
    return $pixels[0];
  } else {
    return \@pixels;
  }
}

=back

=begin __PRIVATE_METHODS__

=head2 Private Methods

=over 4

=item B<_import_file>

Read the .MORE.ACSIS.RECEPTORS array from the given file and configure
the Array object.

 $array->_import_file( $filename );

=cut

sub _import_file {
  my $self = shift;
  my $file = shift;

  # Strip off a trailing ".sdf".
  $file =~ s/\.sdf$//;

  # Make sure the file exists.
  if( ! -e "$file.sdf" ) {
    croak "File $file.sdf does not exist";
  }

  # Set status.
  my $status = &NDF::SAI__OK;

  # Start error handling.
  err_begin( $status );

  # Retrieve the locators for the .MORE.ACSIS.RECEPTORS primitive.
  ( $status, my @locs ) = retrieve_locs( "$file.MORE.ACSIS.RECEPTORS", 'READ', $status );

  # Get the array pointed to by the last locator. Assume we're going
  # to have 16 or fewer receptors.
  dat_get1c( $locs[-1], 16, my @receptors, my $nreceptors, $status );

  # Annul locators.
  dat_annul( $_, $status ) for reverse @locs;

  # Handle errors.
  if( $status != &NDF::SAI__OK ) {
    my $errstr = err_flush_to_string( $status );
    err_annul( $status );
    croak "Error retrieving ACSIS receptor information: $errstr";
  }

  # Store receptors, mapping pixels to detector name. Note that pixels start counting at 1.
  my $i = 1;
  my %receptors = map { $_, $i++ } @receptors;
  $self->{RECEPTORS} = \%receptors;
}

=item B<_pixel_mapping>

Return a hash reference, with keys being pixels and values being
receptors.

=cut

sub _pixel_mapping {
  my $self = shift;
  my %pixels = reverse %{$self->{RECEPTORS}};
  return \%pixels;
}

=item B<_receptor_mapping>

Return a hash reference, with keys being receptors and values being
pixels.

=cut

sub _receptor_mapping {
  my $self = shift;
  return $self->{RECEPTORS};
}

=back

=end __PRIVATE_METHODS__

=head1 AUTHOR

 Brad Cavanagh E<lt>b.cavanagh@jach.hawaii.eduE<gt>

=head1 COPYRIGHT

Copyright (C) 2008 Science and Technology Facilities Council. All
Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful,but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA 02111-1307,
USA

=cut

1;

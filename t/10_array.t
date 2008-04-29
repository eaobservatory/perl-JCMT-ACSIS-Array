#!perl

use Test::More tests => 17;
use Test::Exception;

require_ok( "JCMT::ACSIS::Array" );

my $array = new JCMT::ACSIS::Array( File => "t/data/a20080428_00006_01_ts001" );

isa_ok( $array, "JCMT::ACSIS::Array" );

my $pixel = $array->pixel( 'H04' );
is( $pixel, 4, "Receptor H04 is pixel 4" );

my @pixels = $array->pixel( 'H01', 'H04', 'H09' );
is( $pixels[0], 2, "Receptor H01 is pixel 2 (list context)" );
is( $pixels[1], 4, "Receptor H04 is pixel 4 (list context)" );
is( $pixels[2], 9, "Receptor H09 is pixel 8 (list context)" );

my $pixels = $array->pixel( 'H01', 'H04', 'H09' );
is( $pixels->[0], 2, "Receptor H01 is pixel 2 (scalar context)" );
is( $pixels->[1], 4, "Receptor H04 is pixel 4 (scalar context)" );
is( $pixels->[2], 9, "Receptor H09 is pixel 8 (scalar context)" );

my $receptor = $array->receptor( 3 );
is( $receptor, 'H02', "Pixel 3 is receptor H02" );

my @receptors = $array->receptor( 3, 8, 12 );
is( $receptors[1], 'H08', "Pixel 8 is receptor H08 (list context)" );

my $receptors = $array->receptor( 3, 8, 12 );
is( $receptors->[2], 'H12', "Pixel 12 is receptor H12 (scalar context)" );

my @allreceptors = $array->receptors;
is( $allreceptors[0], 'H00', "First receptor is H00" );

# Test failure conditions.
dies_ok{ my $array2 = new JCMT::ACSIS::Array( "unknown" ); } "No File argument";
dies_ok{ my $array2 = new JCMT::ACSIS::Array( file => "unknown" ); } "Mis-named named argument";
dies_ok{ my $array2 = new JCMT::ACSIS::Array( File => "unknown" ); } "Missing file";
dies_ok{ my $array2 = new JCMT::ACSIS::Array( File => "t/data/6_rimg" ); } "File with no .MORE.SMURF extension";

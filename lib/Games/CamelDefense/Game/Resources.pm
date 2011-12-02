package Games::CamelDefense::Game::Resources;

use strict;
use warnings;
use base 'Exporter';
use FindBin qw($Bin);
our @EXPORT = qw(image_resource);

my $Resource_Path = "$Bin/resources";
sub Set_Path($) { $Resource_Path = shift }

sub image_resource($) {
    my $name = shift;
    return "$Resource_Path/images/$name.png";
}

1;

=head1 NAME

Games::CamelDefense::App::Resources - application resources loader


=head1 SYNOPSIS

  use Games::CamelDefense::Game::Resources;

  # get the path to foo.png in the image dir
  # default is $Bin/resources/images
  $image_file_path = image_resource 'foo';

  # set the resource dir, done by App once on build
  Games::CamelDefense::Game::Resources::Set_Path('/some/image/dir');

=head1 DESCRIPTION

Some game objects need image files- sprite, background image, etc. This package
lets you set the path for image files once, and provides a function to translate
image name to image path in the images resource dir.

=cut


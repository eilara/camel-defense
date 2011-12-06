package Games::CamelDefense::Game::ImageFile;

use Games::CamelDefense::Class qw(Game::Resources);
use Imager;
use aliased 'SDL::Rect';
use aliased 'SDLx::Sprite'           => 'SDLxSprite';
use aliased 'SDLx::Sprite::Animated' => 'SDLxAnimatedSprite';

has file    => (is => 'ro', isa => Str , required => 1);
has stretch => (is => 'ro', isa => Bool, default  => 0);

sub build_sdl_sprite {
    my ($self, $size) = @_;
    my $file = image_resource $self->file;
    $file = $self->scale_file($file, $size) if $self->stretch;
    return SDLxSprite->new(image => $file);
}

sub build_sdl_animated_sprite {
    my ($self, $size, $sequences, $sequence) = @_;
    my $file = image_resource $self->file;
    return SDLxAnimatedSprite->new(
        image     => $file,
        rect      => Rect->new(0, 0, @$size),
        sequences => $sequences,
        sequence  => $sequence,
    );
}

sub scale_file {
    my ($self, $in_file, $size) = @_;
    (my $out_file = $in_file) =~ s/\.png$//;
    $out_file .= "_scaled_to_${\( $size->[0] )}x${\( $size->[1] )}.png";
    my $in_im = Imager->new;
    $in_im->read(file => $in_file) or die "Cannot load $in_file: ", $in_im->errstr;;
    my $out_im = $in_im->scale
        (xpixels => $size->[0], ypixels => $size->[1], type => 'nonprop');
    $out_im->write(file => $out_file) or die "Cannot write $out_file: ", $out_im->errstr;;
    return $out_file;
}

1;

=head1 NAME

Games::CamelDefense::Game::ImageFile - an image resource that can be scaled


=head1 SYNOPSIS

  $image = Games::CamelDefense::Game::ImageFile->new(
      file  => 'myimage', # load $resources_path/images/myimage.png
      scale => 1,         # default is 0, scale image to requested size
                          # when building SDLx Sprite
  );
  # assuming scale is true, build sprite at requested size
  # if scale is false, requested size is ignore and sprite is not scaled
  $sprite          = $image->build_sdl_sprite([200, 100])
  $animated_sprite = $image->build_sdl_animated_sprite([200, 100])
  

=head1 DESCRIPTION

A way to resize images and wrap them in sprites.


=cut



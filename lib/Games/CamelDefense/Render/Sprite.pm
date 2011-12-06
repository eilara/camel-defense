package Games::CamelDefense::Render::Sprite;

use Games::CamelDefense::Role qw(Game::ImageFile);
use Moose::Util::TypeConstraints;
use aliased 'SDLx::Sprite' => 'SDLxSprite';

coerce ImageFile, from Str, via { ImageFile->new(file => $_) };

has image => (
    is       => 'ro',
    isa      => ImageFile, 
    required => 1,
    coerce   => 1,
    handles  => qr/^build_sdl/,
);

has sprite => (
    is         => 'ro',
    isa        => SDLxSprite,
    lazy_build => 1,
    handles    => ['draw_xy'],
);

consume qw(
    Geometry::Rectangular
    Render::Paintable
);

sub _build_sprite {
   my $self = shift;
   return $self->build_sdl_sprite( $self->size );
}

# TODO optimize to less method calls on each paint
sub paint {
    my ($self, $surface) = @_;
    $self->draw_xy($surface, @{$self->pos});
}

1;


package CamelDefense::Game::UI::Button;

use Moose;

with 'CamelDefense::Role::Sprite';

has icon => (is => 'ro', required => 1); # my image def

sub init_image_def { shift->icon }

1;


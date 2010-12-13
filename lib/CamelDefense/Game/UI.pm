package CamelDefense::Game::UI;

use Moose;
use SDL::Events;

with 'CamelDefense::Role::Sprite';

sub init_image_def {{
    image     => '../data/ui.png',
    size      => [640, 48],
}}

sub handle_event {
    my ($self, $e) = @_;
}

1;


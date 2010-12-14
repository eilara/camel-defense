package CamelDefense::Game::UI;

use Moose;
use SDL::Events;
use CamelDefense::Util qw(is_my_event);
use aliased 'CamelDefense::Cursor';

has cursor => (is => 'ro', required => 1, isa => Cursor);

with 'CamelDefense::Role::Sprite';

sub init_image_def {{
    image     => '../data/ui.png',
    size      => [640, 48],
}}

sub handle_event {
    my ($self, $e) = @_;
    return unless is_my_event($e, 0, $self->y, $self);

    $self->cursor->set_default; # dont want build cursor on toolbar
    # route the event to the correct button
    if ($e->type == SDL_MOUSEMOTION) {
    } elsif ($e->type == SDL_MOUSEBUTTONUP) {
    }
}

1;


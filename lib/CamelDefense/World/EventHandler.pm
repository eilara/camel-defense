package CamelDefense::World::EventHandler;

# the world event handler translates events in the world into
# transitions on the world state machine
# and updates the cursor position from the mouse

use Moose;
use SDL::Events;
use SDL::Mouse;
use aliased 'CamelDefense::World::State';
use aliased 'CamelDefense::Cursor';

has state  => (is => 'ro', required => 1, isa => State);
has cursor => (is => 'ro', required => 1, isa => Cursor);

sub handle_event {
    my ($self, $e) = @_;
    my $state = $self->state;

    if ($e->type == SDL_KEYUP && $e->key_sym == SDLK_1) {
        $state->handle_event('init_or_cancel_build_tower');

    } elsif ($e->type == SDL_MOUSEMOTION) {
        my ($x, $y) = ($e->motion_x, $e->motion_y);
        $self->cursor->xy([$x, $y]);
        $state->handle_event('mouse_motion');

    } elsif ($e->type == SDL_MOUSEBUTTONUP) {
        $state->handle_event('build_tower');

    } elsif ($e->type == SDL_APPMOUSEFOCUS) {
        $self->cursor->is_visible($e->active_gain);
    }
}

1;




package CamelDefense::World::EventHandler;

# the world event handler translates events in the world into
# transitions on the world state machine
# and updates the cursor position from the mouse

use Moose;
use MooseX::Types::Moose qw(Int);
use SDL::Events;
use CamelDefense::Util qw(is_in_rect);
use aliased 'CamelDefense::World::State';
use aliased 'CamelDefense::Cursor';

has w      => (is => 'ro', required => 1, isa => Int);
has h      => (is => 'ro', required => 1, isa => Int);
has state  => (is => 'ro', required => 1, isa => State);

sub handle_event {
    my ($self, $e) = @_;
    my $state = $self->state;

    if ($e->type == SDL_KEYUP) {
        my $k = $e->key_sym;
        if ($k == SDLK_ESCAPE) {
            $state->handle_event('cancel_action');
        } elsif ($k >= SDLK_1 && $k <= SDLK_9) {
            # init_build events get the index of the tower type def to be built
            $state->handle_event(init_build => $k - SDLK_1);
        } 

    } else {
        my $is_in_world = is_in_rect(
            $e->motion_x, $e->motion_y, 0, 0, $self->w, $self->h
        );
        if ($e->type == SDL_MOUSEMOTION) {
            $state->handle_event('mouse_motion');
        } elsif ($e->type == SDL_MOUSEBUTTONUP) {
            $state->handle_event('mouse_up')
                if $is_in_world;
        }
    }

}

1;




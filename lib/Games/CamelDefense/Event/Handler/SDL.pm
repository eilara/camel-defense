package Games::CamelDefense::Event::Handler::SDL;

use Games::CamelDefense::Role;
use SDL::Events;

# set this before creating any sdl event handlers
my $SDL_Event_Observable;
sub Set_SDL_Event_Observable { $SDL_Event_Observable = shift }

has sdl_event_observable => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    default  => sub { shift->_build_sdl_event_observable },
);

consume 'Event::Handler';

sub _build_sdl_event_observable {
    my $self = shift;
    $SDL_Event_Observable->add_sdl_event_listener($self);
    return $SDL_Event_Observable;
}

sub sdl_event {
    my ($self, $e) = @_;

    if ($e->type == SDL_MOUSEBUTTONUP) {
        $self->on_mouse_button_up($e->motion_x, $e->motion_y);
        my $button = $e->button_button;
        if ($button == SDL_BUTTON_LEFT) {
            $self->on_left_mouse_button_up($e->motion_x, $e->motion_y);
        } elsif ($button == SDL_BUTTON_RIGHT) {
            $self->on_right_mouse_button_up($e->motion_x, $e->motion_y);
        }

    } elsif ($e->type == SDL_MOUSEBUTTONDOWN) {
        $self->on_mouse_button_down($e->motion_x, $e->motion_y);
        my $button = $e->button_button;
        if ($button == SDL_BUTTON_LEFT) {
            $self->on_left_mouse_button_down($e->motion_x, $e->motion_y);
        } elsif ($button == SDL_BUTTON_RIGHT) {
            $self->on_right_mouse_button_down($e->motion_x, $e->motion_y);
        }

    } elsif ($e->type == SDL_MOUSEMOTION) {
        $self->on_mouse_motion($e->motion_x, $e->motion_y);

    } elsif ($e->type == SDL_APPMOUSEFOCUS) {
        $self->on_app_mouse_focus($e->active_gain);
    }
}

1;

=head1 NAME

Games::CamelDefense::Event::Handler::SDL - get all SDL events


=head1 SYNOPSIS

  package MyGob;
  use Moose;
  with  'Games::CamelDefense::Event::Handler::SDL';
  sub on_mouse_button_up { ... }


=head1 DESCRIPTION

Consume to get all events as method calls on your GOB. Pumps events from the
SDL event pump. You must call C<Set_SDL_Event_Observable()> before constructing
any event handlers, with the global singleton SDL event observer.


=head1 DOES

L<Games::CamelDefense::Event::Handler>


=cut

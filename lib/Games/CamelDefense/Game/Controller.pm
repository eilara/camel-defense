package Games::CamelDefense::Game::Controller;

use Moose;

use EV;
use Coro::AnyEvent;
use AnyEvent;
use Coro;

use SDL;
use SDLx::FPS;
use SDL::Event;
use SDL::Events;

my $FPS = 100;

has [qw(paint_cb event_cb)] => (is => 'rw');

has is_stopped => (is => 'rw', default => 0);

sub run {
    my $self = shift;
    my $fps = SDLx::FPS->new(fps => $FPS);
    my $is_slow;
    async {
        my $paint_cb   = $self->paint_cb;
        my $event_cb   = $self->event_cb;
        my $event      = SDL::Event->new;
        my $tick_start = EV::time;
        my $is_slow;
        while (!$self->is_stopped) {
            SDL::Events::pump_events();
            $event_cb->($event) while SDL::Events::poll_event($event);
#    $update_cb->();
            Coro::AnyEvent::poll;
            $paint_cb->() unless $is_slow;
            $fps->delay;

            my $tick_end = EV::time;
            if ($is_slow) {
                $is_slow = 0;
            } elsif ((1/($tick_end - $tick_start) + 15) < $FPS) {
                $is_slow = 1;
            }
            $tick_start = $tick_end;
        }
    };

    EV::loop;
}

sub stop { shift->is_stopped(1) }

1;

__END__

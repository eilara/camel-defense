package CamelDefense::Game::UI;

use Moose;
use SDL::Events;
use CamelDefense::Util qw(is_my_event);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Game::UI::Button';

my $TOOLBAR_Y = 481;

has cursor   => (is => 'ro', required   => 1, isa => Cursor);
has handler  => (is => 'ro', required   => 1, weak_ref => 1);
has btn_next => (is => 'ro', lazy_build => 1, isa => Button);

sub _build_btn_next { Button->new(
    icon => '../data/ui_button_next.png', # 41x48
)}

with 'CamelDefense::Role::Sprite';

sub init_image_def { '../data/ui_toolbar.png' } # 640x48

sub BUILD {
    my $self = shift;
    $self->btn_next->xy([598, $TOOLBAR_Y]);
}

sub handle_event {
    my ($self, $e) = @_;
    return unless is_my_event($e, 0, $self->y, $self);

    $self->cursor->set_default; # dont want build cursor on toolbar
    # route the event to the correct button
    if ($e->type == SDL_MOUSEMOTION) {
    } elsif ($e->type == SDL_MOUSEBUTTONDOWN) {
    } elsif ($e->type == SDL_MOUSEBUTTONUP) {

        my ($x, $y) = @{ $self->cursor->xy }; 
        return unless $y >= $TOOLBAR_Y + 1;

        if ($x >= 596) {
            $self->handler->start_wave;
        }
    }
}

after render => sub {
    my ($self, $surface) = @_;
    $self->btn_next->render($surface);
};

1;


package CamelDefense::Game::UI;

use Moose;
use SDL::Events;
use CamelDefense::Util qw(is_my_event);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Game::UI::Button';

my $BTN_Y      = 482;
my $BTN_NEXT_X = 597;

has cursor   => (is => 'ro', required   => 1, isa => Cursor);
has handler  => (is => 'ro', required   => 1, weak_ref => 1);
has btn_next => (is => 'ro', lazy_build => 1, isa => Button);

sub _build_btn_next {
    my $self = shift;
    return Button->new(
        click => sub { $self->handler->start_wave },
        icon  => '../data/ui_button_next.png', # 43x44
    );
}

with 'CamelDefense::Role::Sprite';

sub init_image_def { '../data/ui_toolbar.png' } # 640x48

sub BUILD {
    my $self = shift;
    $self->btn_next->xy([$BTN_NEXT_X, $BTN_Y]);
}

sub handle_event {
    my ($self, $e) = @_;
    return unless is_my_event($e, 0, $self->y, $self);

    $self->cursor->set_default; # dont want build cursor on toolbar
    # route the event to the correct button
    my ($x, $y) = @{ $self->cursor->xy }; 
    return unless $y >= $BTN_Y;

    $self->forward_event($e, $x);
}

sub forward_event {
    my ($self, $e, $x) = @_;
    my $type = $e->type;

    my $method = $type == SDL_MOUSEMOTION    ? 'mousemove':
                 $type == SDL_MOUSEBUTTONUP  ? 'mouseup':
                 $type == SDL_MOUSEBUTTONDOWN? 'mousedown':
                 return;

    my $btn = $x >= $BTN_NEXT_X - 2? $self->btn_next:
              return;

    $btn->$method();
}

after render => sub {
    my ($self, $surface) = @_;
    $self->btn_next->render($surface);
};

1;


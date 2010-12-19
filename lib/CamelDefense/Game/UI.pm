package CamelDefense::Game::UI;

use Moose;
use SDL::Events;
use CamelDefense::Util qw(is_my_event);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Game::UI::Button';

my $BTN_NEXT_X = 597;

has cursor   => (is => 'ro', required   => 1, isa => Cursor);
has handler  => (is => 'ro', required   => 1, weak_ref => 1);

has btn_next => (is => 'ro', lazy_build => 1, isa => Button);
has hover    => (is => 'rw'); # if currently hovering

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
    $self->btn_next->x($BTN_NEXT_X);
}

after xy => sub {
    my $self = shift;
    return unless @_;
    $self->btn_next->y($self->y + 2);
};

sub handle_event {
    my ($self, $e) = @_;
    my ($x, $y) = @{ $self->cursor->xy };
    my $is_mine = $y >= $self->y + 2;
    my $hover = $self->hover;

    unless ($is_mine) {
        if ($hover) {
           $hover->mouseleave;
           $self->hover(undef);
        }
        return;
    }

    # dont want build cursor on toolbar or when capturing
    $self->cursor->set_default;

    my $type = $e->type;
    if ($type == SDL_APPMOUSEFOCUS && $e->active_gain && $hover) {
        $hover->mouseleave;
        $self->hover(undef);
        return;
    }

    my $method = $type == SDL_MOUSEBUTTONUP  ? 'mouseup':
                 $type == SDL_MOUSEBUTTONDOWN? 'mousedown':
                 $type == SDL_MOUSEMOTION    ? 'mousemove':
                 return;

    my $btn = 
        $x >= $BTN_NEXT_X - 2? $self->btn_next:
        undef;

    $hover->mouseleave if $hover && (!$btn || $btn ne $hover);
    $self->hover($btn);

    $btn->$method if $btn;
}

after render => sub {
    my ($self, $surface) = @_;
    $self->btn_next->render($surface);
};

1;


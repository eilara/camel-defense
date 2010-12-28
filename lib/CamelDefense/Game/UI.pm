package CamelDefense::Game::UI;

use Moose;
use SDL::Events;
use CamelDefense::Util qw(is_my_event);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Game::UI::Button';
use CamelDefense::Time qw(
    pause_game resume_game is_paused add_pause_listener add_resume_listener
);

my $BTN_NEXT_X   = 597;
my $BTN_PAUSE_X  = $BTN_NEXT_X  - 46;
my $BTN_RESUME_X = $BTN_PAUSE_X - 46;

has cursor  => (is => 'ro', required => 1, isa => Cursor);
has handler => (is => 'ro', required => 1, weak_ref => 1, handles => [qw(
    start_wave no_more_waves add_waves_complete_listener
)]);

has [qw(btn_next btn_pause btn_resume)] =>
    (is => 'ro', lazy_build => 1, isa => Button);

has hover => (is => 'rw'); # if currently hovering

sub _build_btn_next {
    my $self = shift;
    return Button->new(
        click => sub {
            my $btn = shift;
            return if $self->no_more_waves;
            $self->start_wave;
        },
        icon  => '../data/ui_button_next.png', # 43x44
    );
}

sub _build_btn_pause {
    my $self = shift;
    return Button->new(
        click => sub { pause_game },
        icon  => '../data/ui_button_pause.png', # 43x44
    );
}

sub _build_btn_resume {
    my $self = shift;
    return Button->new(
        click       => sub { resume_game },
        icon        => '../data/ui_button_resume_disabled.png', # 43x44
        is_disabled => 1,
    );
}

with 'CamelDefense::Role::Sprite';

sub init_image_def { '../data/ui_toolbar.png' } # 640x48

sub BUILD {
    my $self = shift;
    $self->btn_next->  x($BTN_NEXT_X);
    $self->btn_pause-> x($BTN_PAUSE_X);
    $self->btn_resume->x($BTN_RESUME_X);
    add_pause_listener($self);
    add_resume_listener($self);
    $self->add_world_listeners;
}

sub add_world_listeners {
    my $self = shift;
    $self->add_waves_complete_listener($self);
}

sub waves_complete { shift->btn_next->disable }

sub game_resumed {
    my $self = shift;
    $self->btn_pause->enable;
    $self->btn_resume->disable;
}

sub game_paused {
    my $self = shift;
    $self->btn_pause->disable;
    $self->btn_resume->enable;
}

after xy => sub {
    my $self = shift;
    return unless @_;
    my $y = $self->y + 2;
    $_->y($y) for $self->btn_next, $self->btn_pause, $self->btn_resume;
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
        $x >= $BTN_NEXT_X   - 2? $self->btn_next:
        $x >= $BTN_PAUSE_X  - 2? $self->btn_pause:
        $x >= $BTN_RESUME_X - 2? $self->btn_resume:
        undef;

    $hover->mouseleave if $hover && (!$btn || $btn ne $hover);

    return if !$btn || $btn->is_disabled;

    $self->hover($btn);
    $btn->$method if $btn;
}

after render => sub {
    my ($self, $surface) = @_;
    $_->render($surface) for
        $self->btn_next, $self->btn_pause, $self->btn_resume;
};

1;


package CamelDefense::Game::UI;

use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use SDL::Events;
use CamelDefense::Util qw(is_my_event);
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Game::UI::Button';
use CamelDefense::Time qw(
    pause_game resume_game is_paused add_pause_listener add_resume_listener
);

my $BTN_WIDTH  = 46;
my $BTN_NEXT_X = 597;

has cursor  => (is => 'ro', required => 1, isa => Cursor);
has handler => (is => 'ro', required => 1, weak_ref => 1, handles => [qw(
    start_wave no_more_waves add_waves_complete_listener
    add_player_hp_changed_listener add_player_gold_changed_listener
    player_hp player_gold tower_icons init_build
)]);

has [qw(btn_next btn_pause btn_resume)] =>
    (is => 'ro', lazy_build => 1, isa => Button);

has [qw(tower_buttons all_buttons)] =>
    (is => 'ro', lazy_build => 1, isa => ArrayRef[Button]);

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

sub _build_tower_buttons {
    my $self = shift;
    my $i = 0;
    my @icons = $self->tower_icons;
    my $cnt = @icons;
    return [map {
        my $icon = $_;
        my $idx = $cnt - $i++ - 1;
        Button->new(
            click => sub { $self->init_build($idx) },
            icon  => $icon,
        );
    } reverse @icons];
}

sub _build_all_buttons {
    my $self = shift;
    return [
        $self->btn_next, $self->btn_pause, $self->btn_resume,
        @{ $self->tower_buttons },
    ];
}

with 'CamelDefense::Role::Sprite';

sub init_image_def { '../data/ui_toolbar.png' } # 640x48

sub BUILD {
    my $self = shift;
    my $x = $BTN_NEXT_X;
    for my $b (@{ $self->all_buttons }) {
        $b->x($x);
        $x -= $BTN_WIDTH;
    }
    add_pause_listener($self);
    add_resume_listener($self);
    $self->add_world_listeners;
}

sub add_world_listeners {
    my $self = shift;
    $self->add_waves_complete_listener($self);
    $self->add_player_hp_changed_listener($self);
    $self->add_player_gold_changed_listener($self);
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

sub player_hp_changed {
    my $self = shift;
    my $hp = $self->player_hp;
    # TODO: show blood
}

sub player_gold_changed {
    my $self = shift;
    my $gold = $self->player_gold;
    # TODO: show sparkles
}

after xy => sub {
    my $self = shift;
    return unless @_;
    my $y = $self->y + 2;
    $_->y($y) for @{ $self->all_buttons };
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

    my $idx = int(
        ($x - scalar(@{$self->all_buttons}) * $BTN_WIDTH) /
        $BTN_WIDTH
    ) - 1;
    my $is_hit = $idx >= 1;
    my $btn = $self->all_buttons->[-$idx];

    $hover->mouseleave if $hover && (!$is_hit || $btn ne $hover);

    return if !$is_hit || $btn->is_disabled;

    $self->hover($btn);
    $btn->$method if $btn;
}

after render => sub {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->all_buttons };
    my ($x, $y) = @{$self->xy};
    $surface->draw_gfx_text([$x + 60, $y + 20], 0xFFFF00FF, $self->player_gold);
    $surface->draw_gfx_text([$x + 191, $y + 20], 0xFFFF00FF, $self->player_hp);
};

1;


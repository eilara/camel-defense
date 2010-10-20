package CamelDefense::World;

use Moose;
use SDL::Events;
use SDL::Mouse;
use MooseX::Types::Moose qw(ArrayRef);
use aliased 'SDLx::App';
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::StateMachine';
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Tower';
use aliased 'CamelDefense::Wave';

has app => (is => 'ro', required => 1, isa => App, handles => [qw(w h stop)]);

has [qw(spacing waypoints creep_vel creep_size inter_creep_wait)] =>
    (is => 'ro', required => 1);

has cursor => (is => 'ro', lazy_build => 1, isa => Cursor);
has state  => (is => 'ro', lazy_build => 1, isa => StateMachine);
has grid   => (is => 'ro', lazy_build => 1, isa => Grid, handles => [qw(
    points_px compute_cell_center grid_color
)]);

has towers => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[Tower],
    default  => sub { [] },
);

has waves => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[Wave],
    default  => sub { [] },
);

sub BUILD {
    my $self = shift;
    SDL::Mouse::show_cursor(SDL_DISABLE);
    $self->app->add_event_handler(sub { $self->handle_event(@_) });
    $self->app->add_show_handler(sub { $self->render(@_) });
    $self->app->add_move_handler(sub { $self->move(@_) });
}

sub _build_grid {
    my $self = shift;
    return Grid->new(
        w         => $self->w,
        h         => $self->h,
        spacing   => $self->spacing,
        waypoints => $self->waypoints,
    );
}

sub _build_cursor { Cursor->new }

sub _build_state {
    my $self        = shift;
    my $can_build   = sub { $self->can_build };
    my $build_tower = sub { $self->build_tower };

    return StateMachine->new(
        cursor => $self->cursor,
        states => {
            init => {
                cursor => 'normal',
                events => {
                    space_key_up => {
                        next_state => $can_build,
                    },
                },
            },
            place_tower => {
                cursor => 'place_tower',
                events => {
                    space_key_up => {
                        next_state => 'init',
                    },
                    mouse_motion => {
                        next_state => $can_build,
                    },
                    mouse_button_up => {
                        next_state => 'place_tower',
                        code       => $build_tower,
                    },
                },
            },
            cant_place_tower => {
                cursor => 'cant_place_tower',
                events => {
                    mouse_motion => {
                        next_state => $can_build,
                    },
                    space_key_up => {
                        next_state => 'init',
                    },
                },
            },
    });
}

sub start_wave {
    my $self = shift;
    push @{ $self->waves }, Wave->new(
        creep_vel        => $self->creep_vel,
        creep_size       => $self->creep_size,
        inter_creep_wait => $self->inter_creep_wait,
        waypoints        => $self->points_px,
    );
}

sub handle_event {
    my ($self, $e) = @_;
    my $state = $self->state;

    if ($e->type == SDL_QUIT) {
        $self->stop;

    } elsif ($e->type == SDL_KEYUP && $e->key_sym == SDLK_SPACE) {
        $state->handle_event('space_key_up');

    } elsif ($e->type == SDL_MOUSEMOTION) {
        my ($x, $y) = ($e->motion_x, $e->motion_y);
        $self->cursor->x($x);
        $self->cursor->y($y);
        $state->handle_event('mouse_motion');

    } elsif ($e->type == SDL_MOUSEBUTTONUP) {
        $state->handle_event('mouse_button_up');

    } elsif ($e->type == SDL_APPMOUSEFOCUS) {
        $self->cursor->is_visible($e->active_gain);
    }
}

sub render {
    my $self = shift;
    my $surface = $self->app;
    my $grid_color = $self->grid_color;
    $self->grid->render_markers($surface);
    $_->render_range($surface, $grid_color) for @{ $self->towers };
    $self->grid->render($surface);
    $_->render($surface) for $self->children;
}

sub render_cursor {
    my $self = shift;
    $self->cursor->render($self->app);
}

sub move {
    my ($self, $dt) = @_;
    $_->move($dt) for $self->children;
}

sub can_build {
    my $self = shift;
    my $cursor = $self->cursor;
    return $self->grid->can_build($cursor->x, $cursor->y)?
        'place_tower':
        'cant_place_tower';
}

sub build_tower {
    my $self = shift;
    my $cursor = $self->cursor;
    my $grid = $self->grid;
    my ($x, $y) = ($cursor->x, $cursor->y);
    push @{ $self->towers }, Tower->new(
        world => $self,
        x     => $x,
        y     => $y,
    );
    $grid->add_tower($x, $y);
}

sub children {
    my $self = shift;
    return (@{ $self->towers }, @{ $self->waves });
}

sub aim {
    my ($self, $sx, $sy, $range) = @_;
    for my $wave (@{ $self->waves }) {
        for my $creep (@{ $wave->creeps }) {
            if (
                $creep->is_alive &&
                (_distance($sx, $sy, $creep->x, $creep->y) <= $range)
            ) {
                return $creep;
            }
        }
    }
}

sub _distance {
    my ($x1, $y1, $x2, $y2) = @_;
    return sqrt( ($x1 - $x2)**2 + ($y1 - $y2)**2 );
}


1;


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

has app =>
    (is => 'ro', required => 1, isa => App, handles => [qw(w h stop)]);

has waypoints => (is => 'ro', required => 1);

has cursor => (is => 'ro', lazy_build => 1, isa => Cursor);
has state  => (is => 'ro', lazy_build => 1, isa => StateMachine);

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

with 'MooseX::Role::BuildInstanceOf' => {target => Grid};
has '+grid' => (handles => [qw(
    points_px compute_cell_center grid_color add_tower
)]);
around merge_grid_args => sub {
    my ($orig, $self) = @_;
    my %args = $self->$orig;
    my $marks_args         = delete($args{marks_args})         || [];
    my $waypoint_list_args = delete($args{waypoint_list_args}) || [];
    return (
        marks_args => [w => $self->w, h => $self->h, @$marks_args],
        waypoint_list_args =>
            [waypoints => $self->waypoints, @$waypoint_list_args],
        %args,
    );
};

with 'MooseX::Role::BuildInstanceOf' => {target => Wave, type => 'factory'};
around merge_wave_args => sub {
    my ($orig, $self) = @_;
    my %args = $self->$orig;
    push @{ $args{creep_args} ||= []}, (waypoints => $self->points_px);
    return %args;
};

sub BUILD {
    my $self = shift;
    SDL::Mouse::show_cursor(SDL_DISABLE);
    $self->app->add_event_handler(sub { $self->handle_event(@_) });
    $self->app->add_show_handler(sub { $self->render(@_) });
    $self->app->add_move_handler(sub { $self->move(@_) });
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

sub handle_event {
    my ($self, $e) = @_;
    my $state = $self->state;

    if ($e->type == SDL_QUIT) {
        $self->stop;

    } elsif ($e->type == SDL_KEYUP && $e->key_sym == SDLK_SPACE) {
        $state->handle_event('space_key_up');

    } elsif ($e->type == SDL_MOUSEMOTION) {
        my ($x, $y) = ($e->motion_x, $e->motion_y);
        $self->cursor->xy([$x, $y]);
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

sub start_wave {
    my $self = shift;
    push @{ $self->waves }, $self->wave;
}

sub can_build {
    my $self = shift;
    my $cursor = $self->cursor;
    return $self->grid->can_build(@{$cursor->xy})?
        'place_tower':
        'cant_place_tower';
}

sub build_tower {
    my $self = shift;
    my $cursor = $self->cursor;
    my ($x, $y) = @{$cursor->xy};
    push @{ $self->towers }, Tower->new(
        world => $self,
        xy    => [$x, $y],
    );
    $self->add_tower($x, $y);
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
                $creep->is_in_range($sx, $sy, $range)
            ) {
                return $creep;
            }
        }
    }
}

1;


package CamelDefense::World;

use Moose;
use SDL::Events;
use SDL::Mouse;
use MooseX::Types::Moose qw(ArrayRef CodeRef);
use aliased 'SDLx::App';
use aliased 'SDLx::Surface';
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::StateMachine';
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Tower::Manager' => 'TowerManager';
use aliased 'CamelDefense::Wave::Manager'  => 'WaveManager';

has app =>
    (is => 'ro', required => 1, isa => App, handles => [qw(w h stop)]);

has waypoints => (is => 'ro', required => 1);

has level_complete_handler =>
    (is => 'ro', required => 1, isa => CodeRef, default => sub { sub {} });

has cursor     => (is => 'ro', lazy_build => 1, isa => Cursor);
has state      => (is => 'ro', lazy_build => 1, isa => StateMachine);
has bg_surface => (is => 'ro', lazy_build => 1, isa => Surface);

sub _build_bg_surface {
    my $self = shift;
    return Surface->new(width => $self->w, height => $self->h);
}

# the world has a grid
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

# the world has a wave manager
with 'MooseX::Role::BuildInstanceOf' =>
    {target => WaveManager, prefix => 'wave_manager'};
has '+wave_manager' => (handles => [qw(start_wave aim is_level_complete)]);
around merge_wave_manager_args => sub {
    my ($orig, $self) = @_;
    return (world => $self, $self->$orig);
};

# the world has a tower manager
with 'MooseX::Role::BuildInstanceOf' =>
    {target => TowerManager, prefix => 'tower_manager'};
has '+tower_manager' => (handles => [qw(build_tower)]);
around merge_tower_manager_args => sub {
    my ($orig, $self) = @_;
    return (world => $self, cursor => $self->cursor, $self->$orig);
};

sub BUILD {
    my $self = shift;
    SDL::Mouse::show_cursor(SDL_DISABLE);
    $self->app->add_event_handler(sub { $self->handle_event(@_) });
    $self->app->add_show_handler(sub { $self->render(@_) });
    $self->app->add_move_handler(sub { $self->move(@_) });
}

sub _build_cursor { Cursor->new(world => shift) }

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
                        next_state => 'cant_place_tower',
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

sub move {
    my ($self, $dt) = @_;
    $self->level_complete_handler->()
        if $self->is_level_complete;
    $_->move($dt) for $self->tower_manager, $self->wave_manager;
}

sub render {
    my $self = shift;
    my $surface = $self->app;
    $self->render_bg;
    $_->render($surface) for $self->tower_manager, $self->wave_manager;
}

sub render_bg {
    my $self = shift;
    my $surface = $self->app;


# TODO: would be better to redraw bg layer only when towers change but
#       it looks choppy, needs to test FPS then check why the slowness

# render background, refreshing it if needed
#    my $bg_surface = $self->bg_surface;
#    $self->refresh_bg($bg_surface) if $self->tower_manager->is_dirty;
#    $bg_surface->blit($surface);

    $self->refresh_bg($surface);

    # now render foreground
    $self->grid->render_markers($surface);
    $self->tower_manager->render_bg($surface);
    $self->grid->render($surface);
}

sub refresh_bg {
    my ($self, $surface) = @_;
    $self->grid->render_markers($surface);
    $self->tower_manager->render_bg($surface);
    $self->grid->render($surface);
}

sub render_cursor {
    my $self = shift;
    $self->cursor->render($self->app);
}

sub can_build {
    my $self = shift;
    my $cursor = $self->cursor;
    return $self->grid->can_build(@{$cursor->xy})?
        'place_tower':
        'cant_place_tower';
}

1;


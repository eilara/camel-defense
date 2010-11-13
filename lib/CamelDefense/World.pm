package CamelDefense::World;

use Moose;
use SDL::Mouse;
use SDL::Events;
use MooseX::Types::Moose qw(ArrayRef CodeRef);
use aliased 'SDLx::App';
use aliased 'SDLx::Surface';
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::World::State';
use aliased 'CamelDefense::World::EventHandler';
use aliased 'CamelDefense::Tower::Manager' => 'TowerManager';
use aliased 'CamelDefense::Wave::Manager'  => 'WaveManager';
use aliased 'SDLx::Controller::Coro'       => 'Controller';

has controller => (is => 'ro', required => 1, isa => Controller);

has app =>
    (is => 'ro', required => 1, isa => App, handles => [qw(w h)]);

has waypoints => (is => 'ro', required => 1);

has level_complete_handler =>
    (is => 'ro', required => 1, isa => CodeRef, default => sub { sub {} });

has cursor     => (is => 'ro', lazy_build => 1, isa => Cursor);
has bg_surface => (is => 'ro', lazy_build => 1, isa => Surface);

sub _build_bg_surface {
    my $self = shift;
    return Surface->new(width => $self->w, height => $self->h);
}

# the world has a grid
with 'MooseX::Role::BuildInstanceOf' => {target => Grid};
has '+grid' => (handles => [qw(
    compute_cell_center grid_color add_tower
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
    return (grid => $self->grid, $self->$orig);
};

# the world has a tower manager
with 'MooseX::Role::BuildInstanceOf' =>
    {target => TowerManager, prefix => 'tower_manager'};
around merge_tower_manager_args => sub {
    my ($orig, $self) = @_;
    return (
        wave_manager => $self->wave_manager,
        grid         => $self->grid,
        cursor       => $self->cursor,
        $self->$orig,
    );
};

# the world has a state
with 'MooseX::Role::BuildInstanceOf' =>
    {target => State, prefix => 'state'};
around merge_state_args => sub {
    my ($orig, $self) = @_;
    return (
        cursor        => $self->cursor,
        grid          => $self->grid,
        tower_manager => $self->tower_manager,
        $self->$orig,
    );
};

# the world has an event handler
with 'MooseX::Role::BuildInstanceOf' =>
    {target => EventHandler, prefix => 'event_handler'};
has '+event_handler' => (handles => [qw(handle_event)]);
around merge_event_handler_args => sub {
    my ($orig, $self) = @_;
    return (cursor => $self->cursor, state => $self->state, $self->$orig);
};

sub BUILD {
    my $self = shift;
    SDL::Mouse::show_cursor(SDL_DISABLE);
    my $c = $self->controller;
    $c->add_event_handler(sub { $self->handle_event(@_) });
    $c->add_show_handler(sub { $self->render(@_) });
    $c->add_move_handler(sub { $self->move(@_) });
}

# should move to build instance role
sub _build_cursor {
    my $self = shift;
    my %manager_args = @{$self->tower_manager_args};
    my $tower_args = $manager_args{tower_args};
    return Cursor->new(shadow_args => [
        grid => $self->grid,
        ($tower_args? @$tower_args: ()),
    ]);
}

sub move {
    my ($self, $dt) = @_;
    if ($self->is_level_complete) {
        # TODO: should only be called once not every move
        $self->level_complete_handler->();
    } else {
        $self->wave_manager->move($dt);
    }
}

sub render {
    my $self = shift;
    my $surface = $self->app;
    $self->refresh_bg($surface);
# TODO: would be better to redraw bg layer only when towers change but
#       it looks choppy, needs to test FPS then check why the slowness
    $_->render($surface) for $self->tower_manager, $self->wave_manager;
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

1;


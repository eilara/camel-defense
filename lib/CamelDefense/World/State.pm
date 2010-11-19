package CamelDefense::World::State;

# world state machine handles events of build/cancel tower,
# and mouse motion
# updates cursor to reflect correct state
# calls build tower when tower is built

use Moose;
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::StateMachine';
use aliased 'CamelDefense::Cursor';
use aliased 'CamelDefense::Tower::Manager' => 'TowerManager';

has grid          => (is => 'ro', required => 1, isa => Grid);
has cursor        => (is => 'ro', required => 1, isa => Cursor);
has tower_manager => (is => 'ro', required => 1, isa => TowerManager);

has state => (
    is         => 'ro',
    lazy_build => 1,
    isa        => StateMachine,
    handles    => [qw(handle_event)],
);

sub _build_state {
    my $self        = shift;
    my $cursor      = $self->cursor;
    my $grid        = $self->grid;

    my $build_tower = sub { $self->tower_manager->build_tower };

    my $can_build = sub {
        my $self = shift;
        return $grid->can_build(@{$cursor->xy})?
            'place_tower':
            'cant_place_tower';
    };

    my $init_build = sub {
        my $tower_def_idx = shift;
        $self->tower_manager->configure_next_tower($tower_def_idx);
        $can_build->();
    };

    return StateMachine->new(
        cursor => $cursor,
        states => {
            init => {
                cursor => 'normal',
                events => {
                    init_build => {
                        next_state => $init_build,
                    },
                },
            },
            place_tower => {
                cursor => 'place_tower',
                events => {
                    cancel_action => {
                        next_state => 'init',
                    },
                    mouse_motion => {
                        next_state => $can_build,
                    },
                    mouse_up => {
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
                    cancel_action => {
                        next_state => 'init',
                    },
                },
            },
    });
}

1;


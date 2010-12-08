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

    my $selected_tower;

    my $build_tower = sub { $self->tower_manager->build_tower };

    my $can_build = sub {
        my $self = shift;
        return $grid->can_build(@{$cursor->xy})?
            'place_tower':
            'cant_place_tower';
    };

    my $init_build = sub {
        my $tower_def_idx = shift;
        return undef unless # if no such tower then do nothing
            $self->tower_manager->is_tower_available($tower_def_idx);
        $self->tower_manager->configure_next_tower($tower_def_idx);
        return $can_build->();
    };

    my $init_select = sub {
        my $tower = $grid->select_tower(@{$cursor->xy});
        $selected_tower = $tower if $tower;
        return $tower? 'tower_selected': 'init';
    };

    my $init_deselect = sub {
        if ($selected_tower) {
            $grid->unselect_tower($selected_tower);
            $selected_tower = undef;
        }
    };

    my $init_select_or_deselect = sub {
        my ($x, $y) = @{$cursor->xy};
        my $tower = $grid->select_tower($x, $y);
        if (!$tower || ($selected_tower && ($tower eq $selected_tower))) {
            if ($selected_tower) {
                $grid->unselect_tower($selected_tower);
                $selected_tower = undef;
            }
            return 'init';
        }
        # switch selected
        $grid->unselect_tower($selected_tower);
        $selected_tower = $tower;
        return 'tower_selected';
    };

    return StateMachine->new(
        cursor => $cursor,
        states => {
            init => {
                cursor => 'default',
                events => {
                    init_build => {
                        next_state => $init_build,
                    },
                    mouse_up => {
                        next_state => $init_select,
                    },
                },
            },
            tower_selected => {
                cursor   => 'default',
                events   => {
                    mouse_up => {
                        next_state => $init_select_or_deselect,
                    },
                    cancel_action => {
                        next_state => 'init',
                        code       => $init_deselect,
                    },
                    init_build => {
                        next_state => $init_build,
                        code       => $init_deselect,
                    },
                },
            },
            place_tower => {
                cursor => 'place_tower',
                events => {
                    init_build => {
                        next_state => $init_build,
                    },
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
                    init_build => {
                        next_state => $init_build,
                    },
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


package CamelDefense::Tower::Splash;

use Moose;
use MooseX::Types::Moose qw(Num);
use CamelDefense::Time qw(repeat_work);
use aliased 'CamelDefense::Tower::Projectile';

extends 'CamelDefense::Tower::Base';

has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 1);

with 'CamelDefense::Living::Parent';

# the tower creates and manages projectiles
with 'MooseX::Role::BuildInstanceOf' =>
    {target => Projectile, type => 'factory', prefix => 'projectile'};
around merge_projectile_args => sub {
    my ($orig, $self) = @_;
    return (
        wave_manager => $self->wave_manager,
        target       => $self->current_target,
        begin_xy     => [$self->center_x, $self->center_y - 6],
        parent       => $self,
        idx          => $self->update_next_child_idx,
        $self->$orig,
    );
};

sub init_image_def {{
    image     => '../data/tower_splash.png',
    size      => [15, 15],
    sequences => [
        default          => [[0, 0]],
        place_tower      => [[1, 0]],
        cant_place_tower => [[2, 0]],
        selected         => [[3, 0]],
    ],
}}

sub start {
    my $self = shift;
    repeat_work
        predicate => sub { $self->aim(1) },
        work      => sub { push @{$self->children}, $self->projectile },
        sleep     => $self->cool_off_period;
};

# render projectiles
sub render_attacks {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->children };
};

1;


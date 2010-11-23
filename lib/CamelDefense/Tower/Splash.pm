package CamelDefense::Tower::Splash;

use Moose;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Int Num);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Tower::Projectile';

extends 'CamelDefense::Tower::Base';

has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 1);

has next_projectile_idx => (is => 'rw', required => 1, isa => Int , default => 0);

with 'CamelDefense::Living::Parent';

# the tower creates and manages projectiles
with 'MooseX::Role::BuildInstanceOf' =>
    {target => Projectile, type => 'factory', prefix => 'projectile'};
around merge_projectile_args => sub {
    my ($orig, $self) = @_;
    my $idx           = $self->next_projectile_idx;
    my $target        = $self->current_target;
    $self->next_projectile_idx($idx + 1);
    return (
        wave_manager => $self->wave_manager,
        target       => $self->current_target,
        begin_xy     => [$self->center_x, $self->center_y - 6],
        end_xy       => [$target->center_x, $target->center_y],
        parent       => $self,
        idx          => $idx,
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
    ],
}}

sub start {
    my $self = shift;
    while (1) {
        my $did_fire;
        if ($self->aim(1)) {
            $did_fire = 1;
            push @{$self->children}, $self->projectile;
        }
        sleep $self->cool_off_period if $did_fire;
        $did_fire = 0;
    }
};

# render projectiles
sub render_attacks {
    my ($self, $surface) = @_;
    $_->render($surface) for @{ $self->children };
};

1;

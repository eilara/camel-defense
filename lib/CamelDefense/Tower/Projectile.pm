package CamelDefense::Tower::Projectile;

use Moose;
use Scalar::Util qw(weaken);
use List::Util qw(max);
use Coro;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Bool Num Int Str ArrayRef);
use CamelDefense::Util qw(distance);
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';
use aliased 'CamelDefense::Creep';

extends 'CamelDefense::Living::Base';

has wave_manager => (is => 'ro', required => 1, isa => WaveManager, handles => [qw(find_creeps_in_range)]);
has begin_xy     => (is => 'ro', required => 1, isa => ArrayRef);
has end_xy       => (is => 'ro', required => 1, isa => ArrayRef);
has v            => (is => 'ro', required => 1, isa => Num, default => 300);
has damage       => (is => 'ro', required => 1, isa => Num, default => 0.1);
has range        => (is => 'ro', required => 1, isa => Num, default => 30);

has explosion_radius => (is => 'rw', isa => Num, default => 0);

has target => (is => 'ro', required => 1, isa => Creep, weak_ref => 1);

with qw(
    CamelDefense::Role::Active
    CamelDefense::Role::CenteredSprite
);
with 'CamelDefense::Role::AnimatedSprite'; # needs sprite() from CenteredSprite

sub init_image_def { '../data/tower_splash_projectile.png' }

sub BUILD() {
    my $self = shift;
    $self->xy($self->begin_xy);
}

sub start {
    my $self = shift;
    $self->is_alive(1);
    my $target = $self->target;
    weaken $target;

    my $v            = $self->v;
    my $sleep        = max(1/$v, 1/60); # dont move pixel by 1 pixel if you are fast
    my $step         = $v * $sleep;
    my ($x, $y)      = @{ $self->begin_xy };
    my ($tx, $ty)    = @{$target->xy};
    my ($d, $last_d) = (0, 1_000_000); # never shall there be such a distance

    while (
        ($d = distance($x, $y, $tx, $ty)) > 1
     && $last_d >= $d
    ) {
        my $steps = $d / $step;
        last if $steps < 1;
        $x += ($tx - $x) / $steps;
        $y += ($ty - $y) / $steps;
        $self->xy([$x, $y]);
        sleep $sleep;
        ($tx, $ty) = @{ $target->xy } if $target && $target->is_alive;
        $last_d = $d;
    }

    $_->hit($self->damage) for $self->find_creeps_in_range
        ($self->center_x, $self->center_y, $self->range);

    $self->is_alive(0);
    my $explosion_steps = 6;
    my $explosion_sleep = 1/40;
    my $explosion_step  = ($self->range - 1) / $explosion_steps;
    my $radius          = 1;
    for (1..$explosion_steps) {
        $self->explosion_radius($radius);
        $radius += $explosion_step;
        sleep $explosion_sleep;
    }

    $self->is_shown(0);
}

# render laser to creep
around render => sub {
    my ($orig, $self, $surface) = @_;
    return $orig->($self, $surface) if $self->is_alive;
    my $radius = $self->explosion_radius;
    $surface->draw_circle_filled(
        [$self->center_x, $self->center_y],
        $radius,
        0x9F000050,
    );
    $surface->draw_circle(
        [$self->center_x, $self->center_y],
        $radius,
        0x9F0000FF,
        1,
    );
};
1;


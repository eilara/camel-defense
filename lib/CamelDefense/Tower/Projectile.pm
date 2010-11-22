package CamelDefense::Tower::Projectile;

use Moose;
use List::Util qw(max);
use Coro;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Bool Num Int Str ArrayRef);
use CamelDefense::Util qw(distance);
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

extends 'CamelDefense::Living::Base';

has wave_manager => (is => 'ro', required => 1, isa => WaveManager, handles => [qw(find_creeps_in_range)]);
has begin_xy     => (is => 'ro', required => 1, isa => ArrayRef);
has end_xy       => (is => 'ro', required => 1, isa => ArrayRef);
has v            => (is => 'ro', required => 1, isa => Num, default => 300);
has damage       => (is => 'ro', required => 1, isa => Num, default => 3);
has range        => (is => 'ro', required => 1, isa => Num, default => 30);

has explosion_radius => (is => 'rw', isa => Num, default => 0);

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
    my $self      = shift;
    my $v         = $self->v;
    my $sleep     = max(1/$v, 1/60); # dont move pixel by 1 pixel if you are fast
    my $d         = distance(@{$self->begin_xy}, @{$self->end_xy});
    my $time2live = $d / $v;
    my $steps     = int($time2live / $sleep);
    my ($bx, $by) = @{ $self->begin_xy };
    my ($ex, $ey) = @{ $self->end_xy };
    my $step_x    = ($ex - $bx) / $steps;
    my $step_y    = ($ey - $by) / $steps;
    my ($x, $y)   = ($bx, $by);
    
    $self->is_alive(1);
    for (1.. $steps) {
        $x += $step_x;
        $y += $step_y;
        $self->xy([$x, $y]);
        sleep $sleep;
    }

    $_->hit($self->damage) for $self->find_creeps_in_range
        ($self->center_x, $self->center_y, $self->range);

    $self->is_alive(0);

    my $explosion_steps = $self->range / 4;
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
    my $radius = $self->explosion_radius;
    return $orig->($self, $surface) unless $radius;
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


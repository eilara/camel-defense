package CamelDefense::Tower::Projectile;

use Moose;
use Scalar::Util qw(weaken);
use List::Util qw(max);
use Coro;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Num ArrayRef);
use CamelDefense::Util qw(distance);
use CamelDefense::Time qw(animate move);
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';
use aliased 'CamelDefense::Creep';

extends 'CamelDefense::Living::Base';

has wave_manager => (is => 'ro', required => 1, isa => WaveManager, handles => [qw(find_creeps_in_range)]);
has begin_xy     => (is => 'ro', required => 1, isa => ArrayRef);
has v            => (is => 'ro', required => 1, isa => Num, default => 300);
has damage       => (is => 'ro', required => 1, isa => Num, default => 1);
has range        => (is => 'ro', required => 1, isa => Num, default => 30);

has explosion_radius => (is => 'rw', isa => Num, default => 0);

has target => (is => 'ro', required => 1, isa => Creep, weak_ref => 1);

with qw(
    CamelDefense::Role::Active
    CamelDefense::Role::CenteredSprite
);

sub init_image_def { '../data/tower_splash_projectile.png' }

sub BUILD() {
    my $self = shift;
    $self->xy($self->begin_xy);
}

sub start {
    my $self = shift;
    $self->is_alive(1);
    my $target = $self->target;
    weaken $target; # it could die while we move, don't want ref to it

    move
        xy => sub { $self->xy(@_) },
        to => sub { $target && $target->is_alive? $target->xy: undef },
        v  => $self->v;

    $_->hit($self->damage) for $self->find_creeps_in_range
        ($self->center_x, $self->center_y, $self->range);

    $self->is_alive(0);

    animate
        type  => [linear => 1, $self->range - 1, 6],
        on    => [explosion_radius => $self],
        sleep => 1/40;

    $self->is_shown(0);
}

# only render if we are alive
around render => sub {
    my ($orig, $self, $surface) = @_;
    $orig->($self, $surface) if $self->is_alive;
    my $radius = $self->explosion_radius;
    return unless $radius;

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


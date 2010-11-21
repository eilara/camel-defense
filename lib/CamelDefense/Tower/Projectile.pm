package CamelDefense::Tower::Projectile;

use Moose;
use Coro;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Bool Num Int Str ArrayRef);
use CamelDefense::Util qw(distance);

extends 'CamelDefense::Living::Base';

has begin_xy => (is => 'ro', required => 1, isa => ArrayRef);
has end_xy   => (is => 'ro', required => 1, isa => ArrayRef);
has idx      => (is => 'ro', required => 1, isa => Int);
has v        => (is => 'ro', required => 1, isa => Num, default => 300);
has damage   => (is => 'ro', required => 1, isa => Num, default => 20);
has range    => (is => 'ro', required => 1, isa => Num, default => 30);

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
    my $self  = shift;
    my $v     = $self->v;
    my $sleep = max(1/$v, 1/60); # dont move pixel by 1 pixel if you are fast
    $self->is_alive(1);
    $self->is_alive(0);
    # TODO: animate explosion
    $self->is_shown(0);
}

1;


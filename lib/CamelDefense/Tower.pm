package CamelDefense::Tower;

use Moose;
use MooseX::Types::Moose qw(Num Int);
use Time::HiRes qw(time);
use aliased 'SDLx::Sprite';
use aliased 'CamelDefense::World';
use aliased 'CamelDefense::Creep';

has [qw(x y)] => (is => 'rw', required => 1, isa => Num);

has sprite => (
    is         => 'ro',
    lazy_build => 1,
    isa        => Sprite, 
    handles    => [qw(load draw)],
);

has world => (
    is       => 'ro',
    required => 1,
    isa      => World,
    handles  => [qw(compute_cell_center aim)],
);

has laser_color     => (is => 'ro', isa => Num, default => 0xFF0000FF);
has cool_off_period => (is => 'ro', isa => Num, default => 1.0);
has fire_period     => (is => 'ro', isa => Num, default => 0.5);

has last_fire_time  => (is => 'rw', isa => Num, default => sub { time });
has current_target  => (is => 'rw');

sub _build_sprite {
    my $self = shift;
    my $center = $self->compute_cell_center($self->x, $self->y);
    my $sprite = Sprite->new(image => '../data/tower.png');
    $sprite->x($center->[0] - $sprite->w/2);
    $sprite->y($center->[1] - $sprite->h/2);
    return $sprite;
}

sub move {
    my ($self, $dt)     = @_;
    my $last_fire       = $self->last_fire_time;
    my $cool_off_period = $self->cool_off_period;
    my $fire_period     = $self->fire_period;
    my $diff            = time - $last_fire;

    # tower is either waiting for target, firing, or cooling off
    if ($diff >= $cool_off_period + $fire_period) { # waiting
        if (my $target = $self->aim($self->x, $self->y)) {
            $self->current_target($target);
            $self->last_fire_time(time);
        }
    } elsif ($diff >= $fire_period) { # cooling off
        $self->current_target(undef);
    }
}

sub render {
    my ($self, $surface) = @_;
    $self->draw($surface);
    if (my $target = $self->current_target) {
        my $sprite = $self->sprite;
        $surface->draw_line(
            [$sprite->x + $sprite->w/2, $sprite->y + $sprite->h/2],
            [$target->x, $target->y],
            $self->laser_color, 1,
        );
    }
}

1;


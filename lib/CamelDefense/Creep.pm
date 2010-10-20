package CamelDefense::Creep;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use CamelDefense::Util qw(analyze_right_angle_line distance);

# x y hold creep center coordinates
has [qw(x y)]    => (is => 'rw', required => 1, isa => Num, default => 0);
has v            => (is => 'ro', required => 1, isa => Num);
has size         => (is => 'ro', required => 1, isa => Int);
has color        => (is => 'ro', required => 1, isa => Int, default => 0xFFFFFFFF);
has idx          => (is => 'ro', required => 1, isa => Int); # index in wave
has waypoints    => (is => 'ro', required => 1, isa => ArrayRef[ArrayRef[Int]]);
has waypoint_idx => (is => 'rw', required => 1, isa => Int, default => 0);
has hp           => (is => 'rw', required => 1, isa => Num, default => 10);

sub BUILD() {
    my $self = shift;
    my $wp = $self->waypoints->[0];
    $self->x($wp->[0]);
    $self->y($wp->[1]);
}

# assumes creep only moves in vertical or horizontal direction, no angles
sub move {
    my ($self, $dt) = @_;
    return unless $self->is_alive;

    my $wpi = $self->waypoint_idx;
    my @wps = @{ $self->waypoints };
    return if $wpi == $#wps;                # no more waypoints

    my $wp2       = $wps[$wpi + 1];         # next waypoint
    my ($x1, $y1) = ($self->x , $self->y);  # my pos
    my ($x2, $y2) = ($wp2->[0], $wp2->[1]); # next waypoint pos

    my ($is_horizontal, $dir) = analyze_right_angle_line($x1, $y1, $x2, $y2);

    my $self_to_wp2    = $is_horizontal? $x2 - $x1: $y2 - $y1;
    my $self_to_target = $self->v * $dt;
    my $overshoot      = $self_to_target - abs $self_to_wp2;

    if ($overshoot >= 0) { # overshoot
        $self->x($x2);
        $self->y($y2);
        $self->waypoint_idx($wpi + 1);
        return $self->move($dt * $overshoot / $self_to_target);
    }

    if ($is_horizontal) { $self->x( $x1 + $dir * $self_to_target ) }
    else                { $self->y( $y1 + $dir * $self_to_target ) }

    return $self;
}

sub render {
    my ($self, $surface) = @_;
    my $s = $self->size;
    my $h = $s / 2 - 0.5; # sdl rect does int(), we want round
    my ($x, $y) = ($self->x - $h, $self->y - $h);
    $surface->draw_rect([$x, $y, $s, $s], $self->color);
    $surface->draw_gfx_text([$x+2, $y+2], 0x000000FF, $self->idx);
}

sub hit {
    my ($self, $damage) = @_;
    $self->hp($self->hp - $damage);
}

sub is_alive { shift->hp > 0 }

sub is_in_range {
    my ($self, $x, $y, $range) = @_;
    return distance($self->x, $self->y, $x, $y) <= $range;
}

1;


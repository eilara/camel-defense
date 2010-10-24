package CamelDefense::Creep;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use CamelDefense::Util qw(analyze_right_angle_line distance);

has v            => (is => 'ro', required => 1, isa => Num, default => 10);
has idx          => (is => 'ro', required => 1, isa => Int); # index in wave
has waypoints    => (is => 'ro', required => 1, isa => ArrayRef[ArrayRef[Int]]);
has waypoint_idx => (is => 'rw', required => 1, isa => Int, default => 0);
has hp           => (is => 'rw', required => 1, isa => Num, default => 10);

with 'CamelDefense::Role::CenteredSprite';

sub init_image_file { '../data/creep.png' }

sub BUILD() {
    my $self = shift;
    my $wp = $self->waypoints->[0];
    $self->xy([$wp->[0], $wp->[1]]);
}

# assumes creep only moves in vertical or horizontal direction, no angles
sub move {
    my ($self, $dt) = @_;
    return unless $self->is_alive;

    my $wpi = $self->waypoint_idx;
    my @wps = @{ $self->waypoints };
    return if $wpi == $#wps;                # no more waypoints

    my $wp2       = $wps[$wpi + 1];         # next waypoint
    my ($x1, $y1) = @{ $self->xy };         # my pos
    my ($x2, $y2) = ($wp2->[0], $wp2->[1]); # next waypoint pos

    my ($is_horizontal, $dir) = analyze_right_angle_line($x1, $y1, $x2, $y2);

    my $self_to_wp2    = $is_horizontal? $x2 - $x1: $y2 - $y1;
    my $self_to_target = $self->v * $dt;
    my $overshoot      = $self_to_target - abs $self_to_wp2;

    if ($overshoot >= 0) { # overshoot
        $self->xy([$x2, $y2]);
        $self->waypoint_idx($wpi + 1);
        return $self->move($dt * $overshoot / $self_to_target);
    }

    if ($is_horizontal) { $self->xy([ $x1 + $dir * $self_to_target, $y1 ]) }
    else                { $self->xy([ $x1, $y1 + $dir * $self_to_target ]) }

    return $self;
}

after render => sub {
    my ($self, $surface) = @_;
    my $hp = sprintf("%.1f", $self->hp);
    $surface->draw_gfx_text([$self->sprite_x+2, $self->sprite_y+2], 0x000000FF, $hp);
};

sub hit {
    my ($self, $damage) = @_;
    $self->hp($self->hp - $damage);
}

sub is_alive { shift->hp > 0 }

sub is_in_range {
    my ($self, $x, $y, $range) = @_;
    return distance(@{ $self->xy }, $x, $y) <= $range;
}

1;


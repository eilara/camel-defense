package CamelDefense::Util;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = qw(
    analyze_right_angle_line distance can_tower_hit_creep
    is_in_rect is_my_event
);

sub is_my_event {
    my ($e, $left, $top, $has_width_height) = @_;
    my ($x, $y) = ($e->motion_x, $e->motion_y);
    my ($w, $h) = ($has_width_height->w, $has_width_height->h);
    return is_in_rect($x, $y, $left, $top, $w, $h);
}

sub is_in_rect {
    my ($x, $y, $left, $top, $w, $h) = @_;
    return
        ($x >= $left && $x <= $left + $w) &&
        ($y >= $top  && $y <= $top + $h);
}

sub analyze_right_angle_line {
    my ($x1, $y1, $x2, $y2) = @_;

    my $is_horizontal = $x1 == $x2? 0:
                        $y1 == $y2? 1:
                        die 'Can only analyze horizontal or vertical lines';

    my $dir = $is_horizontal? $x1 <= $x2? 1: -1:
                              $y1 <= $y2? 1: -1;

    # ($is_horizontal, $dir, $is_forward)
    return (1 - $is_horizontal, $dir, $dir == 1? 1: 0);
}

sub distance {
    my ($x1, $y1, $x2, $y2) = @_;
    return sqrt( ($x1 - $x2)**2 + ($y1 - $y2)**2 );
}

sub can_tower_hit_creep($$) {
    my ($tower, $creep) = @_;
    return (
           $creep
        && $creep->is_alive
        && $creep->is_in_range
            ($tower->center_x, $tower->center_y, $tower->range)
     );
}

1;


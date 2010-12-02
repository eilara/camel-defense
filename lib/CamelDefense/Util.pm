package CamelDefense::Util;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = qw(analyze_right_angle_line distance can_tower_hit_creep);

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


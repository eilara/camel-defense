package CamelDefense::Waypoints;

use Moose;
use MooseX::Types::Moose qw(Num Int ArrayRef);
use aliased 'CamelDefense::Grid::Markers';
use CamelDefense::Util qw(analyze_right_angle_line);

has marks => (
    is       => 'ro',
    required => 1,
    isa      => Markers,
    handles  => [qw(spacing compute_cell_center_from_ratio)],
);

has waypoint_color => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 0x5F5F5FFF,
);

has path_color =>
    (is => 'ro', required => 1, isa => Int, default => 0x3F3F3FFF);

has waypoints => ( # waypoints specified as ratio of surface size
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[ArrayRef[Num]],
);

has points_px => ( # center of waypoints in px
    is         => 'ro',
    lazy_build => 1,
    isa        => ArrayRef[ArrayRef[Num]],
);

sub _build_points_px {
    my $self = shift;
    return [map
        { $self->compute_cell_center_from_ratio(@$_) }
        @{ $self->waypoints }
    ];
}

sub render {
    my ($self, $surface) = @_;
    my @centers = @{ $self->points_px };
    my $c = $self->waypoint_color;
    my $path_c = $self->path_color;
    my $s = $self->spacing;
    my ($i, @last_waypoint_xy);

    for my $center (@centers) {
        my ($cx, $cy) = @$center;
        my ($x, $y) = ($cx - $s/2, $cy - $s/2);

        # draw waypoint
        $surface->draw_rect([$x+1, $y+1, $s-1, $s-1], $c);
        # draw waypoint index number
        $surface->draw_gfx_text([$x+3, $y+3], 0x000000FF, ++$i);
        # draw tiny square in the center of the waypoint
        $surface->draw_rect([$cx-1, $cy-1, 3, 3], 0x000000FF);

        # draw rectangle on path to previous waypoint
        if (@last_waypoint_xy) {
            my ($lx, $ly) = (@last_waypoint_xy);
            my ($h, $dir) = analyze_right_angle_line($lx, $ly, $x, $y);
            my ($si, $dx, $dy) = ($s + 1, abs($x - $lx), abs($y - $ly));

            if ($dx > $s or $dy > $s) { # not adjacent in the grid
                my @rect = (
                    $h? $dir == 1? ($lx+$si, $ly+1  , $dx-$si, $s-1   )
                                 : ($x+$si , $ly+1  , $dx-$si, $s-1   )
                      : $dir == 1? ($lx+1  , $ly+$si, $s-1   , $dy-$si)
                                 : ($lx+1  , $y+$si , $s-1   , $dy-$si)
                );
                $surface->draw_rect(\@rect, $path_c);
            };
        }
        @last_waypoint_xy = ($x, $y);
    }
}

1;


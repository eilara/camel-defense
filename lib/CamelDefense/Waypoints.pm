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

has waypoints => ( # waypoints specified as ratio of surface size
                   # each point is specified as the top left corner
                   # x and y coordinates, so 0,0 is top left cell
    is       => 'ro',
    required => 1,
    isa      => ArrayRef[ArrayRef[Num]],
);

has waypoint_color => (
    is       => 'ro',
    required => 1,
    isa      => Int,
    default  => 0x9F9F9FFF,
);

has path_color =>
    (is => 'ro', required => 1, isa => Int, default => 0x7F7F7FFF);

has points_px => ( # center of waypoints in px
    is         => 'ro',
    lazy_build => 1,
    isa        => ArrayRef[ArrayRef[Num]],
);

has [qw(cached_waypoint_rects cached_path_rects)] =>
    (is => 'ro', required => 1, lazy_build => 1, isa => ArrayRef);

sub _build_points_px {
    my $self = shift;
    return [map
        { $self->compute_cell_center_from_ratio(@$_) }
        @{ $self->waypoints }
    ];
}

sub _build_cached_waypoint_rects {
    my $self = shift;
    my $c    = $self->waypoint_color;
    my $s    = $self->spacing;
    return [map {
        my ($cx, $cy) = @$_;
        my ($x, $y) = ($cx - $s/2, $cy - $s/2);
        [ [$x+1, $y+1, $s-1, $s-1], $c ];
    } @{ $self->points_px }];
}

sub _build_cached_path_rects {
    my $self    = shift;
    my @centers = @{ $self->points_px };
    my $c       = $self->path_color;
    my $s       = $self->spacing;
    my @last_waypoint_xy;
    my @out;

    for my $center (@centers) {
        my ($cx, $cy) = @$center;
        my ($x, $y) = ($cx - $s/2, $cy - $s/2);

        if (@last_waypoint_xy) {
            my ($lx, $ly) = (@last_waypoint_xy);
            my ($v, $dir) = analyze_right_angle_line($lx, $ly, $x, $y);
            my $h = 1 - $v;
            my ($si, $dx, $dy) = ($s + 1, abs($x - $lx), abs($y - $ly));

            if ($dx > $s or $dy > $s) { # not adjacent in the grid
                my @rect = (
                    $h? $dir == 1? ($lx+$si, $ly+1  , $dx-$si, $s-1   )
                                 : ($x+$si , $ly+1  , $dx-$si, $s-1   )
                      : $dir == 1? ($lx+1  , $ly+$si, $s-1   , $dy-$si)
                                 : ($lx+1  , $y+$si , $s-1   , $dy-$si)
                );
                push @out, [\@rect, $c];
            };
        }
        @last_waypoint_xy = ($x, $y);
    }
    return \@out;
}

sub render {
    my ($self, $surface) = @_;
    # cant just do draw_rect(@$_) because draw_rect fucks up the rect ($_->[0])
    # argument
    $surface->draw_rect([@{$_->[0]}], $_->[1])
        for @{ $self->cached_waypoint_rects };
    $surface->draw_rect([@{$_->[0]}], $_->[1])
        for @{ $self->cached_path_rects };
}

1;

__END__


        # draw waypoint index number
        $surface->draw_gfx_text([$x+3, $y+3], 0x000000FF, ++$i);
        # draw tiny square in the center of the waypoint
        $surface->draw_rect([$cx-1, $cy-1, 3, 3], 0x000000FF);

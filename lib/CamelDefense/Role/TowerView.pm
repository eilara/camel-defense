package CamelDefense::Role::TowerView;

use Moose::Role;
use MooseX::Types::Moose qw(Num Str);
use aliased 'CamelDefense::World';

has world => (is => 'ro', required => 1, isa => World);
has range => (is => 'ro', isa => Num, default => 100); # in pixels

with 'CamelDefense::Role::GridAlignedSprite';

sub compute_cell_center { shift->world->compute_cell_center(@_) }

sub render_range {
    my ($self, $surface, $color, $is_filled) = @_;
    my $method = 'draw_circle'. ($is_filled? '_filled': '');
    $surface->$method(
        [$self->center_x, $self->center_y],
        $self->range,
        $color,
        1,
    );
}

1;


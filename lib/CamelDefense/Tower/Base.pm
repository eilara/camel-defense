package CamelDefense::Tower::Base;

use Moose;
use MooseX::Types::Moose qw(Num);
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

has wave_manager    => (is => 'ro', required => 1, isa => WaveManager);
has grid            => (is => 'ro', required => 1, isa => Grid, handles => [qw(compute_cell_center)]);

has range           => (is => 'ro', required => 1, isa => Num, default => 100); # in pixels
has cool_off_period => (is => 'ro', required => 1, isa => Num, default => 1.0);
has damage_per_sec  => (is => 'ro', required => 1, isa => Num, default => 10);

with 'CamelDefense::Role::Active';
with 'CamelDefense::Role::GridAlignedSprite';

sub init_image_def { die "Abstract" }
sub start          { die "Abstract" }

# should be called before render, on background layer
sub render_range {
    my ($self, $surface, $color) = @_;
    $surface->draw_circle(
        [$self->center_x, $self->center_y],
        $self->range,
        $color,
        1,
    );
}

1;


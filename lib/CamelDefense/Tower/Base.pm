package CamelDefense::Tower::Base;

use Moose;
use MooseX::Types::Moose qw(Num);
use Coro::Timer qw(sleep);
use Time::HiRes qw(time);
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

has wave_manager => (is => 'ro', required => 1, isa => WaveManager);
has grid         => (is => 'ro', required => 1, isa => Grid, handles => [qw(compute_cell_center)]);
has range        => (is => 'ro', required => 1, isa => Num, default => 100); # in pixels

has current_target => (is => 'rw');

with 'CamelDefense::Role::Active';
with 'CamelDefense::Role::GridAlignedSprite';

sub init_image_def { die "Abstract" }
sub start          { die "Abstract" }

# given this tower class defaults and a hash, what is the merged image def?
sub merge_image_def {
    my ($class, $def) = @_;
    return $def->{image_def} || $class->init_image_def;
}

# given this tower class defaults and a hash, what is the merge range?
sub merge_range {
    my ($class, $def) = @_;
    return $def->{range} ||
           $class->meta->find_attribute_by_name("range")->default;
}

sub aim {
    my ($self, $timeout) = @_;
    my $sleep = 0.1; # aim 10 times a sec
    my $start = time;
    my @args  = ($self->center_x, $self->center_y, $self->range);
    while (time - $start < $timeout) {
        sleep $sleep;
        if (my $target = $self->wave_manager->aim(@args)) {
            $self->current_target($target);
            return $target;
        }
    }
    return undef;
}

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


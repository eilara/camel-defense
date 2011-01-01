package CamelDefense::Tower::Base;

use Moose;
use MooseX::Types::Moose qw(Bool Num);
use CamelDefense::Time qw(poll);
use aliased 'CamelDefense::Grid';
use aliased 'CamelDefense::Wave::Manager' => 'WaveManager';

has wave_manager => (is => 'ro', required => 1, isa => WaveManager, handles => [qw(find_creeps_in_range)]);
has grid         => (is => 'ro', required => 1, isa => Grid, handles => [qw(compute_cell_center)]);
has range        => (is => 'ro', required => 1, isa => Num); # in pixels
has price        => (is => 'ro', required => 1, isa => Num); # in gold

has current_target => (is => 'rw');

has is_selected => (is => 'rw', required => 1, isa => 'Bool', default => 0);

with qw(
    CamelDefense::Role::Active
    CamelDefense::Role::GridAlignedSprite
);
with 'CamelDefense::Role::AnimatedSprite'; # needs sprite() from CenteredSprite

sub init_image_def { die "Abstract" }
sub start          { die "Abstract" }

sub icon {
    my $class = shift;
    $class = lc((split /::/, $class)[-1]);
    return "../data/ui_button_tower_$class.png";
}

sub set_selected {
    my $self = shift;
    $self->is_selected(1);
    $self->sequence_animation('selected');
}

sub set_unselected {
    my $self = shift;
    $self->is_selected(0);
    $self->sequence_animation('default');
}

sub aim {
    my ($self, $timeout) = @_;
    my @args = ($self->center_x, $self->center_y, $self->range);
    my $waves = $self->wave_manager;

    my $target = poll
        timeout   => $timeout,
        sleep     => 0.1,
        predicate => sub { $waves->aim(@args) };

    $self->current_target($target) if $target;
    return $target;
}

sub render_attacks { die "Abstract" }

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


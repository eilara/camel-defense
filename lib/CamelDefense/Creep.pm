package CamelDefense::Creep;

use Moose;
use Coro;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Bool Num Int Str ArrayRef);
use CamelDefense::Util qw(analyze_right_angle_line distance);

has kind         => (is => 'ro', required => 1, isa => Str, default => 'normal');
has v            => (is => 'ro', required => 1, isa => Num, default => 10);
has idx          => (is => 'ro', required => 1, isa => Int); # index in wave
has waypoints    => (is => 'ro', required => 1, isa => ArrayRef[ArrayRef[Int]]);
has hp           => (is => 'rw', required => 1, isa => Num, default => 10);

has start_hp     => (is => 'rw', isa => Num);
has is_in_grid   => (is => 'rw', required => 1, isa => Bool, default => 1);
has is_exploding => (is => 'rw', required => 1, isa => Bool, default => 0);

has coro => (is => 'rw');

with 'CamelDefense::Role::CenteredSprite';
with 'CamelDefense::Role::AnimatedSprite';

sub init_image_def {
    my $self = shift;
    return {
        image     => '../data/creep_'. $self->kind. '.png',
        size      => [21, 21],
        sequences => [
            alive => [[0, 1]],
            death => [map { [$_, 0] } 0..6],
        ],
    };
}

sub BUILD() {
    my $self = shift;
    $self->xy($self->waypoints->[0]);
    $self->start_hp($self->hp);
    $self->coro(async { $self->start });
}

# assumes creep only moves in vertical or horizontal direction, no angles
sub start {
    my $self  = shift;
    my @wps   = @{$self->waypoints};
    my $wp1   = shift @wps;
    my $sleep = 1/$self->v;
    $self->xy([@$wp1]);
    my $xy = $self->xy;
    sleep $sleep;
    for my $wp2 (@wps) {
        my ($is_horizontal, $dir, $is_forward) =
            analyze_right_angle_line(@$wp1, @$wp2);
        my @range = $is_horizontal? $is_forward? ($wp1->[0]..$wp2->[0]):
                                                 ($wp2->[0]..$wp1->[0]):
                                    $is_forward? ($wp1->[1]..$wp2->[1]):
                                                 ($wp2->[1]..$wp1->[1]);
        my $axis = 1 - $is_horizontal;
        for my $i (@range) {
            $xy->[$axis] += $dir;
            $self->_update_sprite_xy;
            sleep $sleep;
        }
        $wp1 = $wp2;
    }
    $self->is_in_grid(0);
}

sub start_death {
    my $self = shift;
    my $sleep = 0.05;
    $self->sequence_animation('death');
    for my $frame (0..5) {
        sleep $sleep;
        $self->next_animation;
    }
    sleep $sleep;
    $self->coro->cancel;
    $self->is_exploding(0);
}

after render => sub {
    my ($self, $surface) = @_;

# draws text of creep hp and index    
#    my $hp = sprintf("%.1f", $self->hp);
#    $surface->draw_gfx_text([$self->sprite_x+2, $self->sprite_y+2], 0x000000FF, $hp);
#    $surface->draw_gfx_text([$self->sprite_x+2, $self->sprite_y+2], 0x000000FF, $self->idx);

    # add health bar
    my $hp_ratio = $self->hp_ratio;
    my ($x, $y) = ($self->sprite_x, $self->sprite_y - 7);
    my $w = $self->w;
    $surface->draw_rect([$x  , $y  , $w  , 4], 0x0);
    $surface->draw_rect([$x+1, $y+1, $w-1, 2], 0xFF0000FF);
    $surface->draw_rect([$x+1, $y+1, $hp_ratio*($w-1), 2], 0x00FF00FF);
};

sub hit {
    my ($self, $damage) = @_;
    my $hp = $self->hp - $damage;
    $self->hp($hp);
    unless ($hp > 0) {
        $self->is_exploding(1);
        async { $self->start_death };
    }
}

sub is_alive { shift->hp > 0 }

sub is_in_game # creep is in game if it needs to be drawn
    { ($_[0]->is_alive || $_[0]->is_exploding) && $_[0]->is_in_grid }

sub is_in_range {
    my ($self, $x, $y, $range) = @_;
    return distance(@{ $self->xy }, $x, $y) <= $range;
}

sub hp_ratio {
    my $self = shift;
    return $self->hp / $self->start_hp;
}

1;


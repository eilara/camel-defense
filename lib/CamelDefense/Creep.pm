package CamelDefense::Creep;

# * is_alive - can be hit
# * is_shown - needs to be drawn
#
# - before enter animation, creep is_shown=1, is_alive=0
# - after enter animation, creep is_shown=1, is_alive=1
#   now it can be hit
# - before leave animation, creep is_shown=1, is_alive=0
# - after leave animation, creep is_shown=0, is_alive=0
# - before starting death animation: is_shown=1, is_alive=0
# - after death animation: is_shown=0, is_alive=0

use Moose;
use Coro;
use Coro::Timer qw(sleep);
use MooseX::Types::Moose qw(Bool Num Int Str ArrayRef);
use CamelDefense::Util qw(analyze_right_angle_line distance);

extends 'CamelDefense::Living::Base';

# kind: normal, fast, slow
has kind      => (is => 'ro', required => 1, isa => Str, default => 'normal');
has v         => (is => 'ro', required => 1, isa => Num, default => 10);
has idx       => (is => 'ro', required => 1, isa => Int); # index in wave
has waypoints => (is => 'ro', required => 1, isa => ArrayRef[ArrayRef[Int]]);
has hp        => (is => 'rw', required => 1, isa => Num, default => 10);

has start_hp  => (is => 'rw', isa => Num);

has coro => (is => 'rw');

with 'CamelDefense::Role::CenteredSprite';
with 'CamelDefense::Role::AnimatedSprite';

sub init_image_def {
    my $self = shift;
    return {
        image     => '../data/creep_'. $self->kind. '.png',
        size      => [21, 21],
        sequences => [
            alive      => [[0, 1]],
            death      => [map { [$_, 0] } 0..6],
            enter_grid => [map { [6 - $_, 1] } 0..6],
            leave_grid => [map { [$_, 1] } 0..6],
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
    $self->animate(enter_grid => 5, 0.06);
    $self->is_alive(1);
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
            # TODO: should move not 1 pixel but as many pixels needed
            #       because last sleep was too long?
            # TODO: should keep a delta and sleep less if needed?
            # TODO: why move 1 pixel per 0.01 secs in 100px/sec speed
            #       if fps=60?
            $xy->[$axis] += $dir;
            $self->_update_sprite_xy;
            sleep $sleep;
        }
        $wp1 = $wp2;
    }
    $self->is_alive(0);
    $self->animate(leave_grid => 5, 0.06);
    $self->is_shown(0);
}

before render => sub {
    my ($self, $surface) = @_;

# draws text of creep hp and index    
#    my $hp = sprintf("%.1f", $self->hp);
#    $surface->draw_gfx_text([$self->sprite_x+2, $self->sprite_y+2], 0x000000FF, $hp);
#    $surface->draw_gfx_text([$self->sprite_x+2, $self->sprite_y+2], 0x000000FF, $self->idx);

    # add health bar
    # TODO: bar should shrink/grow when creep is animated
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
    $hp = 0 if $hp < 0;
    $self->hp($hp);
    unless ($hp > 0) {
        $self->is_alive(0);
        $self->coro->cancel;
        async {
            $self->animate(death => 5, 0.06);
            $self->is_shown(0);
        };
    }
}

sub is_in_range {
    my ($self, $x, $y, $range) = @_;
    return distance(@{ $self->xy }, $x, $y) <= $range;
}

sub hp_ratio {
    my $self = shift;
    return $self->hp / $self->start_hp;
}

1;


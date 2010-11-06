package CamelDefense::Creep;

use Moose;
use Coro;
use CamelDefense::Util qw(rest);
use MooseX::Types::Moose qw(Bool Num Int ArrayRef);
use CamelDefense::Util qw(analyze_right_angle_line distance);

has v         => (is => 'ro', required => 1, isa => Num, default => 10);
has idx       => (is => 'ro', required => 1, isa => Int); # index in wave
has waypoints => (is => 'ro', required => 1, isa => ArrayRef[ArrayRef[Int]]);
has hp        => (is => 'rw', required => 1, isa => Num, default => 10);

has start_hp   => (is => 'rw', isa => Num);
has is_in_grid => (is => 'rw', required => 1, isa => Bool, default => 1);

has coro => (is => 'rw');

with 'CamelDefense::Role::CenteredSprite';

sub init_image_file { '../data/creep_normal.png' }

sub BUILD() {
    my $self = shift;
    $self->xy($self->waypoints->[0]);
    $self->start_hp($self->hp);
    $self->coro(async { $self->start });
}

# assumes creep only moves in vertical or horizontal direction, no angles
sub start {
    my $self = shift;
    my @wps = @{$self->waypoints};
    my $wp1 = shift @wps;
    $self->xy([@$wp1]);
    $self->rest_while_alive;
    for my $wp2 (@wps) {
        my ($is_horizontal, $dir, $is_forward) =
            analyze_right_angle_line(@$wp1, @$wp2);
        my @range = $is_horizontal? $is_forward? ($wp1->[0]..$wp2->[0]):
                                                 ($wp2->[0]..$wp1->[0]):
                                    $is_forward? ($wp1->[1]..$wp2->[1]):
                                                 ($wp2->[1]..$wp1->[1]);
        for my $i (@range) {
            $self->xy->[1 - $is_horizontal] += $dir;
            $self->_update_sprite_xy;
            $self->rest_while_alive;
            print "alive:".$self."\n";
        }
        $wp1 = $wp2;
    }
    $self->is_in_grid(0);
}

sub rest_while_alive {
    my $self = shift;
    rest(1/$self->v);
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
    $self->hp($self->hp - $damage);
    $self->coro->cancel unless $self->is_alive;
}

sub is_alive { shift->hp > 0 }
sub is_in_game { $_[0]->is_alive && $_[0]->is_in_grid }

sub is_in_range {
    my ($self, $x, $y, $range) = @_;
    return distance(@{ $self->xy }, $x, $y) <= $range;
}

sub hp_ratio {
    my $self = shift;
    return $self->hp / $self->start_hp;
}

1;


package CamelDefense::Role::PerformanceMeter;

use Moose::Role;
use MooseX::Types::Moose qw(Int Num);
use Time::HiRes qw(time);
use Data::Average::Expires;
use CamelDefense::Time qw(is_paused);

requires 'render';

has last_point => (is => 'rw', required => 1, isa => Num, default => 0);
has average    => (is => 'ro', required => 1, lazy_build => 1, handles => [qw(
    avg add
)]);

# 5 sec window
sub _build_average { Data::Average::Expires->new(expires_in => 5) }

after render => sub {
    my ($self, $surface) = @_;
    my $last_point = $self->last_point;
    unless ($last_point) {
        $self->last_point(time);
        return;
    }
    my $diff = time - $last_point;
    my $fps = 1 / $diff;
    $self->add($fps);
    my $average = sprintf("%.0f", $self->avg);
    $self->last_point(time);

    $surface->draw_gfx_text([585, 10], 0xFFFF00FF, "FPS=$average");
    $surface->draw_gfx_text([585, 23], 0xFFFF00FF, "PAUSED")
        if is_paused;
};

1;




package CamelDefense::Game::UI::Button;

use Moose;
use MooseX::Types::Moose qw(CodeRef);

with 'CamelDefense::Role::Sprite';

has icon  => (is => 'ro', required => 1); # my image def
has click => (is => 'ro', required => 1, isa => CodeRef);

sub init_image_def { shift->icon }

sub mousemove {
    my $self = shift;
}

sub mousedown {
    my $self = shift;
    my ($x, $y) = @{ $self->xy };
    $self->xy([$x, $y + 1]);
}

sub mouseup {
    my $self = shift;
    my ($x, $y) = @{ $self->xy };
    $self->xy([$x, $y - 1]);
    $self->click->();
}

1;


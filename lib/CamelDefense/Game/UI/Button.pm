package CamelDefense::Game::UI::Button;

use Moose;
use MooseX::Types::Moose qw(CodeRef);

with 'CamelDefense::Role::Sprite';

has icon        => (is => 'rw', required => 1); # my image def
has click       => (is => 'ro', required => 1, isa => CodeRef);
has is_pressed  => (is => 'rw', required => 1, default => 0);
has is_disabled => (is => 'rw', required => 1, default => 0);

sub init_image_def { shift->icon }

sub mousemove {
    my $self = shift;
}

sub mousedown {
    my $self = shift;
    return if $self->is_pressed;
    $self->press;
}

sub mouseup {
    my $self = shift;
    return unless $self->is_pressed;
    $self->depress;
    $self->click->($self);
}

sub mouseleave {
    my $self = shift;
    return unless $self->is_pressed;
    $self->depress;
}

sub press {
    my $self = shift;
    my ($x, $y) = @{ $self->xy };
    $self->xy([$x, $y + 2]);
    $self->is_pressed(1);
}

sub depress {
    my $self = shift;
    my ($x, $y) = @{ $self->xy };
    $self->xy([$x, $y - 2]);
    $self->is_pressed(0);
}

sub disable {
    my $self = shift;
    $self->is_disabled(1);
    my $icon = $self->icon;
    $icon =~ s/\.png$/_disabled.png/;
    $self->load($icon);
    $self->icon($icon);
}

sub enable {
    my $self = shift;
    $self->is_disabled(0);
    my $icon = $self->icon;
    $icon =~ s/_disabled\.png$/.png/;
    $self->load($icon);
    $self->icon($icon);
}

1;


#!/usr/bin/perl

package Games::CamelDefense::eg_GridAlignedSprite;
use Games::CamelDefense::Demo qw(Grid::Markers);

consume qw(Render::Sprite Grid::Aligned);

# ------------------------------------------------------------------------------

package Games::CamelDefense::eg_GridAlignedSprite_Cursor;
use Games::CamelDefense::Demo;

has children => (is => 'ro', required => 1, default => sub { [] });
has markers  => (is => 'ro', required => 1, handles => [qw(cell_center_xy)]);

consume qw(Behavior::Cursor Render::Sprite);

sub on_mouse_button_up {
    my $self = shift;
    push @{$self->children}, Games::CamelDefense::eg_GridAlignedSprite->new(
        rect    => $self->rect,
        image   => $self->image,
        markers => $self->markers,
        layer   => 'middle',
    );
}

# ------------------------------------------------------------------------------

package main;
use Games::CamelDefense::Demo qw(Grid::Markers);
use Games::CamelDefense::App title       => 'Grid Aligned Sprite',
                             size        => [640, 480],
                             layers      => [qw(middle top)],
                             hide_cursor => 1;

my $markers = Markers->new
    (size => App->size, xy => [0, 0], spacing => 32);

my $cursor = Games::CamelDefense::eg_GridAlignedSprite_Cursor->new(
    rect     => [100, 100, 22, 26],
    image    => 'arrow',
    layer    => 'top',
    markers  => $markers,
);

App->run;



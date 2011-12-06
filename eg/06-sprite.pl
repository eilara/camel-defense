#!/usr/bin/perl

package Games::CamelDefense::eg_StickySprite;
use Games::CamelDefense::Demo;

# how to create sprites
# move mouse around to move sprite
# click to drop a sprite at current mouse position
# note that StickySprites are created centered on xy
# while MoveAroundSprite is created with xy at top left

consume 'Render::Sprite';

# ------------------------------------------------------------------------------

package Games::CamelDefense::eg_CursorSprite;
use Games::CamelDefense::Demo;

has children => (is => 'ro', required =>1, default => sub { [] });

consume qw(
    Render::Sprite
    Event::Handler::SDL
);

# hide/show this cursor when entering/leaving app
sub on_app_mouse_focus { shift->is_visible(pop) }

sub on_mouse_motion {
    my ($self, @pos) = @_;
    $self->xy(\@pos);
}

sub on_mouse_button_up {
    my $self = shift;
    push @{$self->children}, Games::CamelDefense::eg_StickySprite->new(
        rect     => $self->rect,
        image    => 'arrow',
        layer    => 'middle',
        centered => 1,
    );
}

# ------------------------------------------------------------------------------

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title       => 'Sprite',
                             layers      => [qw(middle top)],
                             hide_cursor => 1;

my $sprite = Games::CamelDefense::eg_CursorSprite->new(
    rect  => [100, 100, 22, 26],
    image => 'arrow',
    layer => 'top',
);

App->run;



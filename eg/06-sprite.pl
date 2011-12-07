#!/usr/bin/perl

package Games::CamelDefense::eg_StickySprite;
use Games::CamelDefense::Demo;

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
        image    => $self->image,
        layer    => 'middle',
        centered => 1,
    );
}

before paint => sub {
    my ($self, $surface) = @_;
    $surface->draw_gfx_text([260, 200], 0xFFFFFFFF,
        'Click to place a sticky Sprite GOB');
    $surface->draw_gfx_text([190, 220], 0xFFFFFFFF,
        'Note sticky sprite is centered on mouse while cursor is not');
};

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



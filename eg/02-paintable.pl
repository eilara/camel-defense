#!/usr/bin/perl

package Games::CamelDefense::eg_Paintable;
use Games::CamelDefense::Demo;

consume 'Render::Paintable';

sub paint {
    my ($self, $surface) = @_;
    $surface->draw_gfx_text([100, 100], 0xFFFFFFFF, 'A Paintable GOB');
}

# ------------------------------------------------------------------------------

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title => 'Paintable';

my $paintable = Games::CamelDefense::eg_Paintable->new;

App->run;

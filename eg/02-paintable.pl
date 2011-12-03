#!/usr/bin/perl

package Games::CamelDefense::eg_Paintable;
use Moose;
use Games::CamelDefense::Demo;

with 'Games::CamelDefense::Render::Paintable';

sub paint {
    my ($self, $surface) = @_;
    $surface->draw_gfx_text([100, 100], 0xFFFFFFFF, 'I can be painted');
}

package main;
use Games::CamelDefense::Demo;
use Games::CamelDefense::App title => 'Paintable';

my $paintable = Games::CamelDefense::eg_Paintable->new;

App->run;

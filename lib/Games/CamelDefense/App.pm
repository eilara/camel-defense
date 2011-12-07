package Games::CamelDefense::App;

use SDL;
use SDL::Rect;
use SDL::Events;
use SDL::Mouse;
use SDLx::App;
use Games::CamelDefense::Class qw(
    Event::Handler::SDL
    Game::Resources
    Render::Paintable
    Render::LayerManager
    Game::Controller
);

my $Instance;
sub import { # copied from Avenger
    my ($class, %args) = @_;
    my $caller = caller;
    $Instance ||= $class->new(%args);
    {   no strict 'refs';
        *{"${caller}::App"} = sub { $Instance };
    }
}

has title       => (is => 'ro', isa => Str     , default => 'Perl SDL');
has size        => (is => 'ro', isa => ArrayRef, default => sub {[800, 600]});
has bg_color    => (is => 'rw', isa => Int     , default => 0x000000FF);
has hide_cursor => (is => 'ro', isa => Bool    , default => 0);
has resources   => (is => 'ro', isa => Str);

has_event 'sdl_event';

compose_from 'SDLx::App',
    prefix => 'sdl',
    has    => {handles => ['update']},
    inject => sub {
        my $self = shift;
        return (
            w     => $self->w,
            h     => $self->h,
            title => $self->title,
            flags => SDL_DOUBLEBUF|SDL_HWSURFACE,
        );
    };

compose_from LayerManager,
    prefix => 'layer_manager',
    has    => {handles => ['paint']};

compose_from Controller;

sub w { shift->size->[0] }
sub h { shift->size->[1] }

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    push(@{$args{layer_manager_args} ||= []}, layers => delete $args{layers})
        if exists $args{layers};
    return $class->$orig(%args);
};

sub BUILD {
    my $self = shift;

    # must be called before creating paintables or sdl event handlers
    Games::CamelDefense::Event::Handler::SDL::Set_SDL_Event_Observable($self);
    Games::CamelDefense::Render::Paintable::Set_Layer_Manager($self->layer_manager);

    Games::CamelDefense::Game::Resources::Set_Path($self->resources)
        if defined $self->resources;
}

sub run {
    my $self = shift;
    my $sdl  = $self->sdl; # must be created before controller add_event_handler
    my $c    = $self->controller;

    $c->paint_cb(sub { $self->sdl_paint_handler });
    $c->event_cb(sub { $self->sdl_event_handler(@_) });

    SDL::Mouse::show_cursor(SDL_DISABLE) if $self->hide_cursor;
    $c->run; # blocks
}

sub sdl_event_handler {
    my ($self, $e) = @_;
    $self->controller->stop if $e->type == SDL_QUIT;
    $self->sdl_event($e);
}

sub sdl_paint_handler {
    my $self = shift;
    my $surface = $self->sdl;
    my $c = $self->bg_color;
    $surface->draw_rect(undef, $c) if defined $c;
    $self->paint($surface);
    $self->update;
}

1;

=head1 NAME

Games::CamelDefense::App - game application object


=head1 SYNOPSIS

  # only once in your code
  use Games::CamelDefense::App
       title       => 'window title here',
       size        => [640,480],
       hide_cursor => 1,
       bg_color    => 0xFF0000FF,
       resources   => "$Bin/my_image_dir",
       layers      => [qw(trees path enemies)];

  # as many times as you want
  use Games::CamelDefense::App;

  $w         =  App->w;
  $h         = App->h;
  $size      = App->size;      # 2D array ref of w,h
  $resources = App->resources; # resources dir path string
  $title     = App->title;
  $bg_color  = App->bg_color;
  

=head1 DESCRIPTION

Use this package in one place in your game code and provide a hash of app
args. Then you can use the class all over your code and get access to the App
singleton.

Wraps an L<SDLx::App> object.


=cut


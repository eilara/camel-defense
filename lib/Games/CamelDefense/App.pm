package Games::CamelDefense::App;

use Moose;
use MooseX::Types::Moose qw(Bool Int Str ArrayRef);
use SDL;
use SDL::Rect;
use SDL::Events;
use Games::CamelDefense::MooseX::Compose;

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

with 'MooseX::Role::Listenable' => {event => 'sdl_event'};

compose_from 'SDLx::App',
    prefix => 'sdl',
    has    => {handles => [qw(update run)]},
    inject => sub {
        my $self = shift;
        return (
            w     => $self->w,
            h     => $self->h,
            title => $self->title,
            flags => SDL_DOUBLEBUF|SDL_HWSURFACE,
            eoq   => 1  ,
        );
    };

sub w { shift->size->[0] }
sub h { shift->size->[1] }

sub BUILD {
    my $self = shift;

    # must be called before creating paintables or sdl event handlers
    GameFrame::Role::SDLEventHandler::Set_SDL_Event_Observable($self);
#    GameFrame::Role::Paintable::Set_Layer_Manager($self->layer_manager);
#    GameFrame::Role::Paintable::Set_SDL_Main_Surface($self->sdl);
#    GameFrame::ResourceManager::Set_Path($self->resources)
#        if defined $self->resources;
}

#sub run {
#    my $self = shift;
#    my $sdl = $self->sdl; # must be created before controller add_event_handler
#    my $c = $self->controller;
#    $c->paint_cb(sub { $self->sdl_paint_handler });
#    $c->event_cb(sub { $self->sdl_event_handler(@_) });
#    SDL::Mouse::show_cursor(SDL_DISABLE) if $self->hide_cursor;
#    $c->run; # blocks
#}

sub sdl_event_handler {
    my ($self, $e) = @_;
    exit if $e->type == SDL_QUIT;
    $self->sdl_event($e);
}

1;

=head1 NAME

Games::CamelDefense::App - game application object


=head1 SYNOPSIS

  # only once in your code
  use Games::CamelDefense::App
       title => 'window title here',
       size  => [640,480];

  # as many times as you want
  use Games::CamelDefense::App;

  my $w    =  App->w;
  my $h     = App->h;
  my $size  = App->size;   # 2D array ref of w,h
  my $title = App->title;
  

=head1 DESCRIPTION

Use this package in one place in your game code and provide a hash of app
args. Then you can use the class all over your code and get access to the App
singleton.

Wraps an L<SDLx::App> object.


=cut


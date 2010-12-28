package CamelDefense::Game;

use Moose;
use MooseX::Types::Moose qw(ArrayRef HashRef);
use SDL;
use SDL::Mouse;
use SDL::Events;
use aliased 'SDLx::App';
use aliased 'SDLx::Controller::Coro' => 'Controller';
use CamelDefense::Time qw(pause_resume);
use aliased 'CamelDefense::World';
use aliased 'CamelDefense::Game::UI';

sub run {
    my ($class, $config) = @_;
    open my $fh, $config or die "Can't read $config: $!";
    my $data = join '', <$fh>;
    close $fh;
    my $conf = eval $data;
    die "Can't eval [$config]: $@" if $@;
    CamelDefense::Game->new(%$conf)->_run;
}

sub _run { shift->controller->run }

# the game has an sdlx app
with 'MooseX::Role::BuildInstanceOf' => {target => App};
has '+app' => (handles => [qw(w h)]);
around merge_app_args => sub {
    my ($orig, $self) = @_;
    my %args = $self->$orig;
    $args{h} += 48; # UI height
    return (%args);
};

# the game has a UI
with 'MooseX::Role::BuildInstanceOf' =>
    {target => UI, prefix => 'game_ui'};
around merge_game_ui_args => sub {
    my ($orig, $self) = @_;
    return (cursor => $self->cursor, handler => $self, $self->$orig);
};

has worlds => (is => 'ro', required => 1, isa => ArrayRef[HashRef]);

has current_world => (
    is         => 'rw',
    lazy_build => 1,
    isa        => World,
    handles    => [qw(
        cursor
        render_cursor render_cursor_shadow
        start_wave no_more_waves add_waves_complete_listener
        add_player_hp_changed_listener add_player_gold_changed_listener
        player_hp player_gold
    )],
);

sub _build_current_world { shift->build_world(0) }

sub build_world {
    my ($self, $idx) = @_;
    my $def = $self->worlds->[$idx || 0];
    return World->new(
        controller => $self->controller,
        app        => $self->app,
        w          => $self->w,
        h          => $self->h - 48, # UI height
        %$def,
    );
}

sub switch_world {
    my ($self, $idx) = @_;
    my $world = $self->build_world($idx);
    $self->current_world($world);
    $self->ui->add_world_listeners;
}

has controller => (
    is       => 'ro',
    required => 1,
    isa      => Controller,
    default  => sub { Controller->new },
);

sub BUILD {
    my $self = shift;
    $self->current_world; # so world will add handlers before my handlers
                          # for z order reasons
    $self->add_app_handlers;
    SDL::Mouse::show_cursor(SDL_DISABLE); # for some reason must be
                                          # done AFTER handlers are added
    $self->game_ui->xy([0, $self->h - 48]); # ui height
}

sub add_app_handlers {
    my $self = shift;
    $self->controller->add_show_handler(sub { $self->render });
    $self->controller->add_event_handler(sub { $self->handle_event(@_) });
}

sub clean_app_handlers {
    my $self = shift;
    $self->controller->remove_all_handlers;
}

sub handle_event {
    my ($self, $e) = @_;

    if (
        $e->type == SDL_QUIT ||
            ($e->type == SDL_KEYUP && $e->key_sym == SDLK_q)
    ) {
        $self->app->stop;
        exit;

    } elsif ($e->type == SDL_KEYUP && $e->key_sym == SDLK_p) {
        pause_resume;

    } elsif($e->type == SDL_KEYUP && $e->key_sym == SDLK_SPACE) { 
        $self->start_wave;
    }

    $self->game_ui->handle_event($e);
}

sub render {
    my $self = shift;
    my $app = $self->app;
    $self->render_cursor_shadow($self->app);
    $self->game_ui->render($app);
    $self->render_cursor($app);
    $app->update;
}

1;

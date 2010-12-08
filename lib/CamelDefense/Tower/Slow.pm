package CamelDefense::Tower::Slow;

use Moose;
use Coro;
use Scalar::Util qw(weaken);
use Set::Object::Weak qw(set);
use MooseX::Types::Moose qw(Int Num ArrayRef);
use CamelDefense::Time qw(animate poll repeat_work);
use CamelDefense::Util qw(can_tower_hit_creep);
use aliased 'CamelDefense::Tower::Projectile';
use aliased 'CamelDefense::Creep';

my $ATTACK_COLOR = 0x39257235;

extends 'CamelDefense::Tower::Base';

has cool_off_period   => (is => 'ro', required => 1, isa => Num, default => 1);
has slow_percent      => (is => 'ro', required => 1, isa => Num, default => 13);

has explosion_radius  => (is => 'rw', isa => Num, default => 0);
has explosion_color   => (is => 'rw', isa => Num, default => $ATTACK_COLOR);

has current_targets => (
    is       => 'ro',
    required => 1,
    isa      => 'Set::Object::Weak',
    default  => sub { Set::Object::Weak->new },
    handles  => {
        add_targets    => 'insert',
        remove_targets => 'remove',
        targets        => 'elements',
    },
);

has velocities_removed => (is => 'ro', required => 1, default => sub { {} });

sub init_image_def {{
    image     => '../data/tower_slow.png',
    size      => [15, 15],
    sequences => [
        default          => [[0, 0]],
        place_tower      => [[1, 0]],
        cant_place_tower => [[2, 0]],
        selected         => [[3, 0]],
    ],
}}

sub start {
    my $self = shift;
    $self->start_cleanup_thread;
    repeat_work
        predicate => sub { $self->aim(1) },
        work      => sub { $self->attack },
        sleep     => $self->cool_off_period;
}

# TODO: Active role should handle sub threads
# TODO: creeps should keep track of their spells, and there should be a 
#       spell thing which does all this stuff. creeps need to show spells
# TODO: polling is bad, should be able to just write the expression for
#       currently in range creeps and get events when they change

# thread that cleans creeps leaving range
sub start_cleanup_thread {
    my $self = shift;
    my $x = async {
        my @range = ();
        while (1) {
            my @out_of_range_targets = @{
                poll predicate => sub {
                    my @ts = grep { !can_tower_hit_creep($self, $_) }
                                  $self->targets;
                    @ts? \@ts: undef;
                }
            };
            $self->remove_targets(@out_of_range_targets);
            my $vs = $self->velocities_removed;
            for my $target (@out_of_range_targets)
                { $target->haste(delete $vs->{$target}) if $target }
        }
    };
}

sub attack {
    my $self = shift;    
    $self->find_and_slow_creeps;

    # explode then fade away
    animate
        type  => [linear => 1, $self->range, 6],
        on    => [explosion_radius => $self],
        sleep => 1/50;
    animate
        type  => [linear => $ATTACK_COLOR, 0x39257205, 5],
        on    => [explosion_color => $self],
        sleep => 1/15;

    $self->explosion_radius(0);
    $self->explosion_color($ATTACK_COLOR);
}

sub find_and_slow_creeps {
    my $self = shift;    
    my @args = ($self->center_x, $self->center_y, $self->range);
    my $targets = $self->find_creeps_in_range(@args);
    if ($targets) {
        my $slow = $self->slow_percent;
        my $vs = $self->velocities_removed;
        for my $target (@$targets)
            { $vs->{$target} += $target->slow($slow) }
        $self->add_targets(@$targets);
    }
}

# render projectiles
sub render_attacks {
    my ($self, $surface) = @_;
    my $radius = $self->explosion_radius;
    return unless $radius;
    $surface->draw_circle_filled(
        [$self->center_x, $self->center_y],
        $radius,
        int($self->explosion_color),
    );
};

1;


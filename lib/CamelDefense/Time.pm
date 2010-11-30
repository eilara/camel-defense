package CamelDefense::Time;

use strict;
use warnings;
use Coro;
use Coro::Timer qw(sleep);
use Time::HiRes qw(time);
use List::Util qw(max);
use CamelDefense::Util qw(distance);
use base 'Exporter';

our @EXPORT_OK = qw(
    animate interval poll repeat_work work_while move
);

sub work_while {
    my (%args)    = @_;
    my $sleep     = $args{sleep};
    my $predicate = $args{predicate} || 1;
    my $work      = $args{work};
    my $timeout   = $args{timeout};
    my $start     = time;
    my $time_pred = $timeout? sub { time - $start < $timeout }: sub { 1 };
    while ($time_pred->() && $predicate->()) {
        $work->();
        sleep $sleep;
    }
}

sub repeat_work(%) {
    my (%args)    = @_;
    my $sleep     = $args{sleep};
    my $predicate = $args{predicate};
    my $work      = $args{work};
    while (1) {
        if ($predicate->()) {
            $work->();
            sleep $sleep;
        }
    }
}

sub poll(%) {
    my (%args)    = @_;
    my $sleep     = $args{sleep};
    my $timeout   = $args{timeout};
    my $predicate = $args{predicate};
    my $start     = time;
    my $time_pred = $timeout? sub { time - $start < $timeout }: sub { 1 };
    while ($time_pred->()) {
        sleep $sleep;
        if (my $result = $predicate->()) {
            return $result;
        }
    }
    return undef;
}

sub interval(%) {
    my $block;
    my (%args) = @_;
    my $sleep  = $args{sleep};
    my $times  = $args{times};
    my $step   = $args{step};
    my $start  = $args{start};
	$block     = $start? sub { $start->(@_); $block = $step }: $step;
	
    for my $i (1..$times) {
        $block->($i);
        sleep $sleep;
    }
}

sub animate(%) {
    my (%args) = @_;
    my $sleep = $args{sleep};
    my ($method, $obj) = @{$args{on}};
    my ($type, $begin, $end, $steps) = @{$args{type}}; 

    my $step = ($end - $begin) / $steps;
    my $value = $begin;
    for (1..$steps) {
        $obj->$method($value);
        $value += $step;
        sleep $sleep;
    }
    $obj->$method($end);
}

sub move(%) {
    my (%args)    = @_;
    my $xy        = $args{xy};
    my $to        = $args{to};
    my $v         = $args{v};
    my $sleep     = max(1/$v, 1/60); # dont move pixel by 1 pixel if you are fast
    my $step      = $v * $sleep;
    my ($x1, $y1) = @{ $xy->() };
    my ($x2, $y2) = @{ $to->() };
    $to->(undef); # if $to is a queue of move commands
    my ($d, $last_d);

    while (
        ($d = distance($x1, $y1, $x2, $y2)) > 1
     && (!$last_d || $last_d >= $d)
    ) {
        my $steps = $d / $step;
        last if $steps < 1;
        $x1 += ($x2 - $x1) / $steps;
        $y1 += ($y2 - $y1) / $steps;
        $xy->([$x1, $y1]);
        sleep $sleep;
        if (my $to_xy = $to->()) {
            ($x2, $y2) = @$to_xy;
            $last_d = undef; # if queue of commands
        } else {
            $last_d = $d;
        }
    }

    $xy->([$x2, $y2]);
}

1;


package CamelDefense::Time;

use strict;
use warnings;
use Coro;
use Coro::Timer qw(sleep);
use Time::HiRes qw(time);
use base 'Exporter';

our @EXPORT_OK = qw(animate interval poll repeat_work work_while);

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
    my (%args) = @_;
    my $sleep = $args{sleep};
    my $times = $args{times};
    my $code  = $args{code};
    for my $i (1..$times) {
        $code->($i);
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

1;


package CamelDefense::Util;

use strict;
use warnings;
use Coro;
use Coro::Timer qw(sleep);
use Time::HiRes qw(time);
use base 'Exporter';

our @EXPORT_OK =
    qw(analyze_right_angle_line distance
       animate interval poll repeat_work work_while);

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
    while (time - $start < $timeout) {
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

sub analyze_right_angle_line {
    my ($x1, $y1, $x2, $y2) = @_;

    my $is_horizontal = $x1 == $x2? 0:
                        $y1 == $y2? 1:
                        die 'Can only analyze horizontal or vertical lines';

    my $dir = $is_horizontal? $x1 <= $x2? 1: -1:
                              $y1 <= $y2? 1: -1;

    # ($is_horizontal, $dir, $is_forward)
    return (1 - $is_horizontal, $dir, $dir == 1? 1: 0);
}

sub distance {
    my ($x1, $y1, $x2, $y2) = @_;
    return sqrt( ($x1 - $x2)**2 + ($y1 - $y2)**2 );
}

1;


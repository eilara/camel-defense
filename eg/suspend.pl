#!/usr/bin/perl

use strict;
use warnings;
use SDLx::Controller::Coro;
use Coro;
use Coro::EV;
use EV;
use AnyEvent;
use Time::HiRes qw(time);
use Coro::Timer qw(sleep);
$|=1;

my $start = time;
sub rep($) {
    my $m = shift;
    my $t = sprintf("%.2f", time - $start);
    print "[$t] $m\n";
}
my $controller = SDLx::Controller::Coro->new;
my ($t1, $pause_duration, $pause_time, $orig_sleep, $timer_orig_start, $resume_signal);
$orig_sleep = 6;
$resume_signal = AnyEvent->condvar;

my $c1 = async {
    rep "2: before sleep";
    $timer_orig_start = time;
    $t1 = EV::timer $orig_sleep, 0, Coro::rouse_cb;
    Coro::rouse_wait;
    if ($pause_time) {
        my $end_of_timer_time = time;
        $resume_signal->recv;
        my $new_sleep = ($pause_duration - (time - $end_of_timer_time));
        $t1 = EV::timer $new_sleep, 0, Coro::rouse_cb;
        Coro::rouse_wait;
    } elsif ($pause_duration) {
        $t1 = EV::timer $pause_duration, 0, Coro::rouse_cb;
        Coro::rouse_wait;
    }
    rep "2: after sleep";
};

my $c2 = async {

    sleep 2;
    rep "1: before suspend";
    $pause_duration = undef;
    $pause_time = time;
    rep "1: after suspend";

    sleep 8;
    rep "1: before resume";
    $pause_duration = time - $pause_time;
    $pause_time = undef;
    $resume_signal->send;
    rep "1: after resume";
    sleep 1;
};

rep "MAIN 1";
$controller->run;
rep "MAIN 2";



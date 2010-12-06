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
sub rep($$) {
    my ($thread, $message) = @_;
    my $time = sprintf("%.2f", time - $start);
    print "[$time] ($thread) $message\n";
}

my (%thread_1, %main_thread);
$thread_1{sleep} = 5;    

my $controller = SDLx::Controller::Coro->new;
start();
$controller->run;

sub start {
    $thread_1{coro}    = async { start_thread_1() };
    $main_thread{coro} = async { start_main_thread() };
}

sub start_thread_1 {
    rep th_1 => 1;
    $thread_1{timer} = EV::timer $thread_1{sleep}, 0, Coro::rouse_cb;
    Coro::rouse_wait;
    rep th_1 => 2;
}

sub start_main_thread {
    rep main => 1;
    sleep 1;
    $thread_1{timer}->invoke;
    rep main => 2;
}


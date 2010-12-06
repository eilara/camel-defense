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
use Test::More qw(no_plan);
$|=1;
my $start = time;
sub rep($$) {
    my ($thread, $message) = @_;
    my $time = sprintf("%.2f", time - $start);
    diag "      [$time] ($thread) $message\n";
}
my $controller = SDLx::Controller::Coro->new;
async { run_tests(
    no_pause  => '...   .SS   .SS',
#    one_pause => '..S.. .SSSS .SSSSS',
)};
$controller->run;

sub run_tests {
    my (%tests) = @_;
    run_test($_, $tests{$_}) for keys %tests;
    exit;
}

sub run_test {
    my ($name, $desc) = @_;
    diag "running $name => $desc";
    my ($desc_contoller, $desc_child, $desc_expected) =
        map { [parse_sleep_and_pause($_)] } split / +/, $desc;
    my $child_thread =
        async { start_child_thread($desc_child) };
    my $controller_thread =
        async { start_controller_thread($desc_contoller, $child_thread) };
}

sub parse_sleep_and_pause {
    my $in = shift;
    my @out;
    while ($in =~ s/^(\.+)(S*)//) {
        my ($x, $y) = ($1 || '', $2 || '');
        push @out, [length($x), length($y)];
    }
    return @out;
}

sub start_child_thread {
    my $desc = shift;
    rep child => 'thread start';
    for my $d (@$desc) {
        my ($wait, $sleep) = @$d;
        sleep($wait) if $wait;
        _sleep($sleep) if $sleep;
    }
    rep child => 'thread complete';
}

sub start_controller_thread {
    my ($desc, $child_thread) = @_;
    rep main => 'thread start';
    for my $d (@$desc) {
        my ($wait, $pause) = @$d;
        sleep($wait) if $wait;
        if ($pause) {
            _pause($child_thread);
            sleep($pause);
            _resume($child_thread);
    }
    rep main => 'thread complete';
}

sub _sleep {
}

sub _pause {
}

sub _reumse {
}

__END__


my (%thread_1, %main_thread);

$thread_1{sleep} = 5;
my @pause_times = ( # [when, how long]
    [1, 2],
);

my $Is_Paused = 0;
my $Resume_Signal = AnyEvent->condvar;

my $controller = SDLx::Controller::Coro->new;
start();
$controller->run;

sub start {
    $thread_1{coro}    = async { start_thread_1() };
    $main_thread{coro} = async { start_main_thread() };
}

sub start_thread_1 {
    rep th_1 => 1;
    my $sleep_start = time;
    $thread_1{timer} = EV::timer $thread_1{sleep}, 0, Coro::rouse_cb;
    Coro::rouse_wait;
    rep th_1 => 'timer complete';
    if ($Is_Paused) {
        my $sleep_performed = time - $sleep_start;
        # dont sleep less than 1/100th of a sec
        my $sleep_left = $thread_1{sleep} - $sleep_performed;
        $sleep_left = 0 if $sleep_left < 1/100;
        rep th_1 => 'waiting for resume';
        $Resume_Signal->recv;
        rep th_1 => 'got resume';
        if ($sleep_left) {
            $thread_1{timer} = EV::timer $sleep_left, 0, Coro::rouse_cb;
            Coro::rouse_wait;
        }
    }
    rep th_1 => 2;
}

sub start_main_thread {
    rep main => 1;
    my ($pause_when, $pause_duration) = @{ $pause_times[0] };
    sleep $pause_when;
    pause_thread_1();
    sleep $pause_duration;
    resume_thread_1();
    rep main => 2;
}

sub pause_thread_1 {
    rep main => 'pause start';
    $Is_Paused = 1;
    $thread_1{timer}->invoke;
    rep main => 'pause done';
}

sub resume_thread_1 {
    rep main => 'resume start';
    $Is_Paused = 0;
    $Resume_Signal->send;
    rep main => 'resume done';
}



__END__

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



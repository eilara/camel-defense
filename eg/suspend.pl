#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(ceil);
use Sub::Call::Recur;
use SDLx::Controller::Coro;
use Coro;
use Coro::EV;
use EV;
use AnyEvent;
use Time::HiRes qw(time);
use Coro::Timer qw(sleep);
use Test::More qw(no_plan);
$|=1;
my $start;
sub rep($$) {
    my ($thread, $message) = @_;
    my $time = sprintf("%.2f", time - $start);
    diag "      [$time]".(' ' x ( $time*4 ))." ($thread) $message\n";
}
my $controller = SDLx::Controller::Coro->new;

my $Timer_Dict = {};
my $Is_Paused;
my $Resume_Signal = AnyEvent->condvar;

async { run_tests(
    no_pause   => '...   .SS    .SS',
    one_pause  => '..P   .SSS   .SSSS',
    long_pause => '..PP  .SS    .SSSSS',
    two_pause  => '..P.P .SSSSS .SSSSSSS',
)};
$controller->run;

sub run_tests {
    my (%tests) = @_;
    run_test($_, $tests{$_}) for keys %tests;
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
    $start = time;
    $child_thread->join;
}

sub parse_sleep_and_pause {
    my $in = shift;
    my @out;
    while ($in =~ s/^(\.+)([SP]*)//) {
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
        rep child => "wait start ($wait)";
        sleep($wait) if $wait;
        rep child => "wait complete ($wait)";
        _sleep($sleep) if $sleep;
    }
    rep child => 'thread complete';
}

sub start_controller_thread {
    my ($desc, $child_thread) = @_;
    rep main => 'thread start';
    for my $d (@$desc) {
        my ($wait, $pause) = @$d;
        rep main => "wait start ($wait)";
        sleep($wait) if $wait;
        rep main => "wait complete ($wait)";
        if ($pause) {
            _pause($child_thread);
            sleep($pause);
            _resume($child_thread);
        }
    }
    rep main => 'thread complete';
}

sub _sleep {
    my ($sleep, $nesting) = @_;
    $nesting ||= 0;
    rep _sleep => "sleep start ($sleep:$nesting)";

    my $sleep_start = time;
    $Timer_Dict->{$Coro::current} = EV::timer $sleep, 0, Coro::rouse_cb;
    Coro::rouse_wait;
    delete $Timer_Dict->{$Coro::current};
    rep _sleep => "timer invoked ($sleep:$nesting)";

    if ($Is_Paused) {
        my $sleep_left = $sleep - (time - $sleep_start);
        $Resume_Signal->recv;
        recur($sleep_left) if $sleep_left > 1/100; # dont sleep less than 1/100th of a sec
    }
    rep _sleep => "sleep complete ($sleep:$nesting)";
}

sub _pause {
    my $thread = shift;
    rep _pause => 1;
    $Is_Paused = 1;
    delete($Timer_Dict->{$thread})->invoke;
    rep _pause => 2;
}

sub _resume {
    my $thread = shift;
    rep _resume => 1;
    $Is_Paused = 0;
    $Resume_Signal->send;
    rep _resume => 2;
}

__END__

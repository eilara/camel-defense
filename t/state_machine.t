#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use Test::More;
use aliased 'Test::MockObject';
use aliased 'CamelDefense::StateMachine';

my ($state_1_event_2_called, $cursor_state);

my $cursor = MockObject->new;
$cursor->mock(change_to => sub { $cursor_state = pop });
$cursor->change_to('normal');

my $state = StateMachine->new(
    cursor => $cursor,
    states => {
        init => {
            cursor  => 'normal',
            events  => {
                event_1 => {
                    next_state => sub { 'state_1' },
                },
            },
        },
        state_1 => {
            cursor  => sub { 'state_1_cursor' },
            events  => {
                event_1 => {
                    next_state => 'init',
                },
                event_2 => {
                    next_state => 'init',
                    code       => sub { $state_1_event_2_called = 1 },
                },
            },
        },
});

ok !$state_1_event_2_called, 'state 1 event 2 not called at 1st';
is $cursor_state, 'normal', 'cursor starts normal';

$state->handle_event('event_2');
ok !$state_1_event_2_called, 'state 1 event 2 not called after empty event';
is $cursor_state, 'normal', 'cursor normal after empty event';

$state->handle_event('event_1');
ok !$state_1_event_2_called, 'state 1 event 2 not called after init event 1';
is $cursor_state, 'state_1_cursor', 'cursor changed when moving to state 1';

$state->handle_event('event_2');
ok $state_1_event_2_called, 'state 1 event 2 called after state 1 event 2';
is $cursor_state, 'normal', 'cursor returned to normal when moving to init';
$state_1_event_2_called = 0;

done_testing();

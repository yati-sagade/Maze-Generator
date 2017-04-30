package Maze::Generator::Cell::Link;
use strict;
use warnings;
use Moo;

has from => (
    weak_ref => 1,
    is       => 'rw',
);

has to => (
    is => 'rw',
);

has open => (
    is  => 'rw',
    default => sub { 0 },
);


1;

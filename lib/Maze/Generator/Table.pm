package Maze::Generator::Table;
use strict;
use warnings;
use Scalar::Util qw(refaddr);
use Moo;

has primary => (
    is      => "ro",
    isa     => "ArrayRef",
    default => [],
);

has secondary => (
    is      => "ro",
    isa     => "HashRef",
    default => {},
);

has next_id => (
    is      => "rw",
    isa     => "Int",
    default => 0,
);

sub hash {
    my $self = shift;
}

sub add {
    my ($self, $key, $value) = @_;
}

1;

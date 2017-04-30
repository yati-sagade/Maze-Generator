package Maze::Generator::Cell;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number reftype blessed);
use Carp qw(croak);
use Moo;

use Maze::Generator::Cell::Link;

our $MAX_INDEX_BITS = 8;

my %OPP_DIRECTIONS = (
    north => 'south',
    east  => 'west',
    west  => 'east',
    south => 'north',
);

sub MAX_INDEX_VAL { 2 ** $MAX_INDEX_BITS - 1 }

sub _validate_index {
    my $val = shift;
    croak sprintf "$val is not a number in [0,%d].", MAX_INDEX_VAL
        if !looks_like_number($val)
         || $val < 0
         || $val > MAX_INDEX_VAL;
}

sub _validate_neighbor_cell {
    my $val = shift;
    return unless defined $val;
    my $class = blessed $val;
    croak sprintf "$val is not a Maze::Generator::Cell object"
        if !$class || $class ne __PACKAGE__;
}

has north => (
    is  => 'rw',
    isa => \&_validate_neighbor_cell,
    default => undef,
    trigger => 1,
);

has south => (
    is  => 'rw',
    isa => \&_validate_neighbor_cell,
    default => undef,
    trigger => 1,
);

has east => (
    is  => 'rw',
    isa => \&_validate_neighbor_cell,
    default => undef,
    trigger => 1,
);

has west => (
    is  => 'rw',
    isa => \&_validate_neighbor_cell,
    default => undef,
    trigger => 1,
);

has row => (
    is  => 'ro',
    isa => \&_validate_index,
    required => 1,
);

has col => (
    is  => 'ro',
    isa => \&_validate_index,
    required => 1,
);

has links => (
    is      => 'ro',
    isa     => sub {
        croak "$_[0] is not a hashref." if reftype($_[0]) ne "HASH";
    },
    default => sub { +{} },
);

sub add_neighbor {
    my ($self, $cell, $options) = @_;
    my $bidi = $options->{bidirectional} // 1;
    $self->links->{$cell->hash} =
        Maze::Generator::Cell::Link->new(
            from => $self, to => $cell, open => $options->{link}
        );
    $cell->add_neighbor($self, {%$options, bidirectional => 0})
        if $bidi;
    my $direction = $self->_get_direction_relation($cell);
    $self->$direction($cell) if $direction;
}

sub hash {
    my $self = shift;
    return ($self->row << 8) | $self->col;
}

sub link {
    my $self    = shift;
    my $other   = shift;
    my $options = shift // {};
    croak "Attempt to link to cell which is not a neighbor."
        if !$self->is_neighboring_to($other);
    $self->links->{$other->hash}->open(1);
    $other->link($self, { bidirectional => 0 })
        if $options->{bidirectional};
}

sub unlink {
    my ($self, $other) = @_;
    my $options = shift // {};
    $self->links->{$other->hash}->open(0)
        if $self->is_neighboring_to($other);
    $other->unlink($self, { bidirectional => 0 })
        if $options->{bidirectional};
}

sub is_neighboring_to {
    my ($self, $other) = @_;
    return exists $self->links->{$other->hash};
}

sub is_linked_to {
    my ($self, $other) = @_;
    return $self->is_neighboring_to($other)
        && $self->links->{$other->hash}->open;
}

sub _get_direction_relation {
    my ($self, $cell) = @_;
    return 'north'
        if $cell->row == $self->row - 1
        && $cell->col == $self->col;

    return 'south'
        if $cell->row == $self->row + 1
        && $cell->col == $self->col;

    return 'east'
        if $cell->row == $self->row
        && $cell->col == $self->col + 1;

    return 'west'
        if $cell->row == $self->row
        && $cell->col == $self->col - 1;

    return;
}

sub neighbors {
    my $self = shift;
    return [map { $_->to } values %{$self->links}];
}

sub linked_neighbors {
    my $self = shift;
    return [grep { $self->is_linked_to($_) } @{$self->neighbors}];
}


{
    no strict "refs";
    # grep food:
    # sub _trigger_east
    # sub _trigger_north
    # sub _trigger_west
    # sub _trigger_south
    for my $dir (qw(north east south west)) {
        *{"_trigger_${dir}"} = sub {
            my ($self, $val) = @_;
            croak "Attempt to set non-neighbor $dir neighbour"
                unless $self->is_neighboring_to($val);
        };
    }
}

1;

__END__

=pod

=head1 NAME

Maze::Generator::Cell

=head1 SYNOPSIS

=over

=item Constructing a Cell

    my $cell = Maze::Generator::Cell->new(row => $row, col => $col);

=item Uniquely identify a cell within a grid by a hash derived from its row and col:

    my $hash_integer = $cell->hash;


=item Adding a neighbour

    my $n = Maze::Generator::Cell->new(row => $row+1, col => $col);
    $cell->add_neighbor($n);
    $cell->neighbors;   # $n

=back

=head1 DESCRIPTION

The cell abstraction, indexed by a row and a column.


=cut


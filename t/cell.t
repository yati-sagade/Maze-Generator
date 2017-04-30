use strict;
use warnings;
use Test::More tests => 20;
use Test::Exception;

my $CLASS;
BEGIN {
    $CLASS = "Maze::Generator::Cell";
    use_ok $CLASS or die;
}

can_ok $CLASS, qw(
    links
    row
    col
    linked_neighbors
    neighbors
    hash
    north
    south
    east
    west
);

#############################################################################
isa_ok
    my $cell = $CLASS->new(row => 3, col => 1),
    $CLASS,
    'A new cell object.';

is $cell->row, 3, 'row should be correctly set.';
is $cell->col, 1, 'col should be correctly set.';
is $cell->hash, (3<<8)|1, 'hash should be correctly computed.';

isa_ok
    my $another_cell = $CLASS->new(row => 1, col => 2),
    $CLASS,
    'Another cell object.';

$cell->add_neighbor($another_cell, {link => 1});

is_deeply [$another_cell], $cell->neighbors, 'Neighbors from primary side';
is_deeply [$cell], $another_cell->neighbors, 'Neighbors from secondary side';

is_deeply
    [$another_cell],
    $another_cell->neighbors->[0]->neighbors,
    'Reading linked cell of the only linked cell should return the original cell';

ok $cell->is_linked_to($another_cell), 'Checking linkedness';
ok $another_cell->is_linked_to($cell), 'Checking linkedness from the other side';

$cell = $CLASS->new(row => 3, col => 1);
my $north = $CLASS->new(row => 2, col => 1);
throws_ok {
    $cell->link($north);
} qr/\QAttempt to link to cell which is not a neighbor/i, 'Linking to a non-neighbor should fail';

$cell->add_neighbor($north);
is_deeply [$north], $cell->neighbors, 'Neighbour should be set properly';
is_deeply [], $cell->linked_neighbors, 'There should be no linked neighbors when we just add the first neighbor';

is_deeply [$cell], $north->neighbors, 'Neighbour should be set properly from other side';
is_deeply [], $north->linked_neighbors, 'There should be no linked neighbors from the other side when a neighbor is only added.';
is_deeply $north->south, $cell, 'Directional neighbour should be set properly';
is_deeply $cell->north, $north, 'Directional neighbour should be set properly from the other side';

throws_ok {
    $cell->north($CLASS->new(row => 0, col => 1))
} qr/\QAttempt to set/i, 'Adding a disconnected node as neighbour should fail';


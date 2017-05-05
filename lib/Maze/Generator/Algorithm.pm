package Maze::Generator::Algorithm;
use strictures 2;
use Moo::Role;

requires 'name';

requires 'description';

sub generate {
    my ($self, $grid) = @_;
    ...
}


1;

__END__

=pod

=head1 Maze::Generator::Algorithm

Main trait for maze generation algorithms.

=head1 SYNOPSIS

    package Maze::Generator::Algorithm::BinaryTree;
    use strictures 2;
    use Moo;
    with 'Maze::Generator::Algorithm';

    has name => "binary_tree";

    has description => "The binary tree algorithm for maze generation";

    sub generate {
        my ($grid) = @_; # A Maze::Generator::Grid object.
        ...
        return $grid;
    }

=cut

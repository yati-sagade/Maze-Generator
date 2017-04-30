package Maze::Generator::Validations;
use strict;
use warnings;
use Exporter qw(import);
use Scalar::Util qw(looks_like_number reftype blessed);
use Carp qw(croak);

our @EXPORT_OK = qw(
    validate_index
);

sub _max_val_for_bits {
    my $bits = shift;
    return 2**$bits - 1;
}

sub validate_index {
    my ($val, $max_bits) = @_;
    my $max_val = _max_val_for_bits($max_bits);
    croak "$val is not a number in [0, $max_val]",
        if !looks_like_number($val)
         || $val < 0
         || $val > $max_val;
}


1;

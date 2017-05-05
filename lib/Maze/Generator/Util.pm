package Maze::Generator::Util;
use strictures 2;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    random_choice
);

sub random_choice {
    my ($items) = @_;
    my $index = int(rand(scalar @$items));
    my $ret = $items->[$index];
    if ($ret) {
        return $ret;
    }
    use feature qw(say);
    say "Have " . scalar(@$items) . " items, index found as $index.";
}


1;

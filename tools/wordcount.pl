#!/usr/bin/perl
use v5.38;
use warnings;

=head1 NAME

wordcount.pl - Count the words and lines of code in markdown.

=cut

my $num_words = 0;
my $num_code_lines = 0;
my $is_in_code_block = 0;
while (<>) {
    if (/^```/) {
        $is_in_code_block = !$is_in_code_block;
    }
    elsif ($is_in_code_block) {
        $num_code_lines++;
    }
    else {
        $num_words += scalar(split /\s+/);
    }
}

say "Words: $num_words";
say "Code lines: $num_code_lines";

__END__
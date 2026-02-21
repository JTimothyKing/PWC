#!/usr/bin/perl
use v5.38;
use warnings;

=head1 NAME

new_test.pl - Create a new test file for a Perl Weekly Challenge task.

=head1 SYNOPSIS

    perl tools/new_test.pl <challenge_dir> <task_id>

    # example
    perl tools/new_test.pl challenge-291 ch-1

=head1 DESCRIPTION

This script creates a new test file for a Perl Weekly Challenge task,
based on the template of existing test files. It takes the challenge
directory and task ID as arguments, and generates a test file with the
appropriate name and structure.

=cut

use FindBin qw($RealBin);
use Path::Tiny;

my ($challenge_dir_name, $task_id) = @ARGV;

die "Usage: $0 <challenge_dir> <task_id>\n    e.g. $0 challenge-291 ch-1\n"
    unless defined $challenge_dir_name && defined $task_id;

# Derive the challenge number from the directory name (e.g. "challenge-291" -> "291")
my ($challenge_num) = $challenge_dir_name =~ /(\d+)/
    or die "Cannot determine challenge number from '$challenge_dir_name'\n";

# Derive the task number from the task ID (e.g. "ch-1" -> "1")
my ($task_num) = $task_id =~ /(\d+)/
    or die "Cannot determine task number from '$task_id'\n";

my $workspace_dir = path($RealBin)->parent;
my $challenge_dir = $workspace_dir->child($challenge_dir_name);
my $t_dir         = $challenge_dir->child('t');

die "Challenge directory '$challenge_dir' does not exist.\n" unless $challenge_dir->is_dir;

$t_dir->mkpath unless $t_dir->is_dir;

my $test_file = $t_dir->child("$task_id.t");
die "Test file '$test_file' already exists.\n" if $test_file->exists;

my $content = <<"END_TEMPLATE";
#!/usr/bin/env perl
use v5.38;
use warnings;

use Test2::V0;
use Test2::Tools::Spec;

use FindBin qw(\$RealBin);

use PwcTask;
use Path::Tiny;

=head1 NAME

$challenge_dir_name/t/$task_id.t - Test for Perl Weekly Challenge #$challenge_num Task $task_num: TASK NAME HERE.

=head1 SYNOPSIS

    # run all tests
    yath $challenge_dir_name/t/$task_id.t

    # run single test or case
    T2_WORKFLOW=test_NAME yath $challenge_dir_name/t/$task_id.t

=head1 DESCRIPTION

Tests for Perl Weekly Challenge #$challenge_num Task $task_num: TASK NAME HERE,
by Tim King L<https://github.com/JTimothyKing>.

=cut

my \$challenge_dir = path(\$RealBin)->parent;
my \$run;

before_case initialize_case => sub { \$run = undef; };

my \$task = PwcTask->new(\$challenge_dir, "$task_id");
for my \$case (\$task->language_cases) {
    diag "Adding case for ", \$case->name;
    case \$case->name => sub { \$run = \$case->prepare };
}

=head1 TESTS

=head2 example_1

    Input:
    Output:

=cut

tests example_1 => sub {
    plan(1);
    is(\$run->(), undef, 'Example 1');
};

done_testing();
END_TEMPLATE

$test_file->spew($content);
say "Created test file: $test_file";


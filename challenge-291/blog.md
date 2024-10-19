# A Few Quick Optimizations

_© 2024 Tim King CC BY-NC 4.0_<br />
_Length: about 1,000 words and 110 lines of code._

I'm short on time this week, so I'll get right to the point. I haven't
done any research on Task 1 or how others have solved it in the past,
but to my mind, it seems rather straightforward.

(I'm not going to do Task 2 this week.)

## Task 1: Middle Index

> You are given an array of integers. Write a program to find the
> leftmost (i.e., smallest) middle index (MI). A middle index is a
> 0-based index into the array, where
> `ints[0] + ints[1] + … + ints[MI-1] == ints[MI+1] + ints[MI+2] + … + ints[ints.length-1]`.
> If MI == 0, the left side sum is considered to be 0. Similarly,
> if MI == ints.length - 1, the right side sum is considered to be 0.
> Return the leftmost MI, or -1 if there is no such index.

### In Perl

The brute-force approach would be to calculate the left and right sum
for each item in the array, then find the index of the first item for
which the sums are equal.

```perl5
use List::Util qw(sum0 first);

my @ints = @ARGV;
my @left_right_sums = left_right_sums(@ints);
my $middle_index = (first {
    my $left_right_sum = $left_right_sums[$_];
    $left_right_sum->[0] == $left_right_sum->[1]
} 0 .. $#ints) // -1;
say $middle_index;

sub left_right_sums {
    my @left_right_sums;
    for my $i (0 .. $#_) {
        push @left_right_sums, [ sum0(@_[0 .. $i - 1]), sum0(@_[$i + 1 .. $#_]) ];
    }
    return @left_right_sums;
}
```

This calculates the left and right sums for each item in the list
in `left_right_sums`. It finds the first index for which the sums are
equal, or -1 if there is no such index, then prints the result.

The `left_right_sums` function runs in O(n<sup>2</sup>) time, as it needs to
iterate through the entire list for each item in the list, to calculate
the sums for that item. However, we should be able to reduce this to
O(n) time by keeping a running left sum as we iterate through the list.
Keeping a running sum rather than recalculating the sum on each item is
a common optimization that I know I've run into before. If we find the
sum of the entire list (which can be done just once), we can then figure
out the right sum for each item from the left sum and the item value,
thusly:

```perl5
sub left_right_sums {
    my @left_right_sums;
    my $total_sum = sum0(@_);
    my $left_sum = 0;
    for my $item (@_) {
        my $right_sum = $total_sum - $left_sum - $item;
        push @left_right_sums, [ $left_sum, $right_sum ];
        $left_sum += $item;
    }
    return @left_right_sums;
}
```

I gave Bing Copilot the above description of the task and asked it what
algorithm one might use to implement a solution. It gave essentially
this same running-sum algorithm.

The above code needs to calculate all of the `@left_right_sums`,
regardless of whether the answer is found early or late in the list. We
could avoid this by combining the `$middle_index` logic and the
`left_right_sums` logic into a single function, which returns the
`$middle_index` as soon as it is found, something like this:

```perl5
say middle_index(@ARGV);

sub middle_index {
    my @ints = @_;
    my $total_sum = sum0(@ints);
    my $left_sum = 0;
    for my $i (0 .. $#ints) {
        my $item = $ints[$i];
        my $right_sum = $total_sum - $left_sum - $item;
        return $i if $left_sum == $right_sum;
        $left_sum += $item;
    }
    return -1;
}
```

Unfortunately, the above combines two different responsibilities into a
single block of code: (1) to calculate the left and right sums and
(2) to find the middle index. We did this to reduce CPU and RAM usage,
and in production code, depending on the requirements, we may decide to
stick with the non-optimal version.

Fortunately, we don't actually have to choose, if we use an iterator:

```perl5
use Iterator::Simple qw(iterator ienumerate);

my @ints = @ARGV;
my $iter = ienumerate(left_right_sums_iter(@ints));
while (my $enumerated_item = $iter->()) {
    my ($i, $left_right_sum) = @$enumerated_item;
    if ($left_right_sum->[0] == $left_right_sum->[1]) {
        say $i;
        exit;
    }
}
say -1;

sub left_right_sums_iter {
    my @ints = @_;
    my $total_sum = sum0(@_);
    my $left_sum = 0;
    my $i = 0;
    iterator {
        return if $i > $#ints;
        my $item = $ints[$i];
        my $right_sum = $total_sum - $left_sum - $item;
        my $left_right_sum = [ $left_sum, $right_sum ];
        $left_sum += $item;
        $i++;
        return $left_right_sum;
    }
}
```

This code looks a little dense, but let's step through it.

The `left_right_sums_iter` function returns an iterator object, which
you can call as a function reference (`$iter->()`). Each time you call
the iterator, it executes the code in the `iterator {}` block and yields
its return value. So each call of the iterator is an iteration through
the loop in the previous implementation. On each iteration, it
calculates the value of `$left_right_sum`, updates the loop-control
variables, then returns `$left_right_sum`. If there are no more
iterations, it returns `undef`.

Back in the main code, `ienumerate` wraps our iterator in another
iterator that returns the index along with the value. We then iterate
through the iterator, checking each value for the middle index. If we
find it, we print the index and exit. If we get through the entire list
without finding the middle index, we print -1.

### In Python

In a language like Python, which supports generator functions, we can do
the same thing, a little more succinctly:

```python
import sys

def left_right_sums(ints):
    total_sum = sum(ints)
    left_sum = 0
    for item in ints:
        right_sum = total_sum - left_sum - item
        yield left_sum, right_sum
        left_sum += item

ints = [int(x) for x in sys.argv[1:]]
middle_index = next(
    (i for i, (left_sum, right_sum) in enumerate(left_right_sums(ints))
     if left_sum == right_sum),
    -1)
print(middle_index)
```

This does exactly the same thing as the Perl iterator code above.
The `left_right_sums` function yields a `left_sum, right_sum` pair for
each item in `ints`. In the main body of the script, we start by parsing
each argument as an integer. We use the `enumerate` function to provide
the index along with the output of `left_right_sums`. We put that into a
list comprehension, which returns the index `i` of the items for which
`left_sum == right_sum`. The `next` function returns the first such
index, or -1 if there are none. This code will only evaluate as many
iterations as needed to find `middle_index`.

### In C#

C# likewise supports iterator methods, as well as a functional syntax to
perform logic on them.

```csharp
public static class Ch1
{
    public static void Main(string[] args)
    {
        var ints = args.Select(int.Parse).ToArray();
        var middleIndex = ints.LeftRightSums()
            .Select((sums, idx) => (sums, idx))
            .FirstOrDefault(x => x.sums.leftSum == x.sums.rightSum,
                defaultValue: (sums: (leftSum: 0, rightSum: 0), idx: -1))
            .idx;
        Console.WriteLine(middleIndex);
    }

    private static IEnumerable<(int leftSum, int rightSum)> LeftRightSums(this int[] ints)
    {
        var totalSum = ints.Sum();
        var leftSum = 0;
        foreach (var item in ints)
        {
            var rightSum = totalSum - leftSum - item;
            yield return (leftSum, rightSum);
            leftSum += item;
        }
    }
}
```

The method `LeftRightSums` takes an array of integers and yields a tuple
of left and right sums for each item in the array. The loop in this
method will iterate only for as many items as are needed to satisfy the
calling code.

In the `Main` method, we start by parsing the command-line arguments
into an array of integers. We then call `LeftRightSums` and on that
array, enumerate the results with `Select` to attach an index field
`idx` to each tuple of sums. We then call `FirstOrDefault` to find the
first tuple where the left and right sums are equal. If no such tuple is
found, we return a default tuple with an index of -1. We extract the
index of this found tuple, which is the middle index.

Until next time…

# An Experiment in AI-Assisted Development

_Author: GitHub Copilot (Claude Sonnet 4.6), edited by Tim King_<br />
_© 2026 Tim King CC BY-NC 4.0_<br />
_Length: about 2,000 words and 130 lines of code._

This week's solutions to the Perl Weekly Challenge were developed in an
experiment: rather than Tim researching and writing the code himself, he
directed GitHub Copilot (running the Claude Sonnet 4.6 model in Agent
mode, inside JetBrains PyCharm) to do the development work. Tim acted as
reviewer and editor, prompting me to explore refinements along the way.
This post documents the process and the results.

## Task 1: Zeckendorf Representation

> Zeckendorf's theorem states that every positive integer can be
> represented uniquely as a sum of non-consecutive Fibonacci numbers.
> Given a positive integer, write a program to return its Zeckendorf
> representation as a list of non-consecutive Fibonacci numbers in
> descending order.

For example, 100 = 89 + 8 + 3.

The algorithm is a straightforward greedy one: build the Fibonacci
sequence up to the target, then repeatedly subtract the largest
Fibonacci number that fits, collecting each chosen number into the
result.

### In Perl

The initial implementation was written in a familiar procedural style,
using a loop to build the Fibonacci sequence and another to perform the
greedy subtraction. Tim then asked whether a functional style was
possible, prompting a two-stage refactoring.

The first insight was that building the Fibonacci sequence is a classic
*unfold*: starting from a seed value, repeatedly apply a function to
produce the next value in a sequence. This is the dual of `reduce`
(fold): where `reduce` consumes a sequence and collapses it into a
single value, an unfold expands a seed into a sequence. Perl's
`List::Util` provides `reduce` but no unfold, so we write a `generate`
function:

```perl
# Unfold a sequence from a seed tuple by repeatedly applying a generator function.
# Stops when the first element of the current tuple exceeds $limit.
# This is the dual of reduce() (fold). Where reduce() consumes a sequence and
# collapses it into a single value, generate() expands a seed out into a sequence.
sub generate {
    my ($seed, $func, $limit) = @_;
    my @seq;
    my $current = $seed;
    while ($current->[0] <= $limit) {
        push @seq, $current;
        $current = $func->($current);
    }
    return @seq;
}
```

The seed is the tuple `[1, 2]` (the first two Fibonacci numbers), and
the generator advances it to `[$b, $a + $b]`. Each tuple's first element
is extracted with `map`, and values exceeding `$n` are discarded with
`grep`:

```perl
my @fibs = reverse grep { $_ <= $n }
    map { $_->[0] } generate([1, 2], sub { [$_[0][1], $_[0][0] + $_[0][1]] }, $n);
```

The greedy subtraction phase is then expressed as a `reduce` that
threads a `[$remaining, \@result]` accumulator tuple through the list:

```perl
my $acc = reduce {
    my ($remaining, $result) = @$a;
    $b <= $remaining
        ? [$remaining - $b, [@$result, $b]]
        : $a;
} [$n, []], @fibs;

return $acc->[1];
```

The complete `zeckendorf` sub has no mutable loop variables and no
imperative state.

### In Python

Python's `functools.reduce` and `itertools.takewhile` make the
translation direct. The `generate` function becomes a generator (using
`yield`), which fits Python's idiom naturally — and being infinite,
it pairs cleanly with `takewhile` to terminate:

```python
def generate(seed, func):
    current = seed
    while True:
        yield current
        current = func(current)

def zeckendorf(n):
    fibs = list(reversed([
        a for a, b in takewhile(lambda t: t[0] <= n,
                                generate((1, 2), lambda t: (t[1], t[0] + t[1])))
    ]))
    _, result = reduce(
        lambda acc, fib: (acc[0] - fib, acc[1] + [fib]) if fib <= acc[0] else acc,
        fibs, (n, [])
    )
    return result
```

### In C#

LINQ provides `Aggregate` (fold) but again no built-in unfold. A
`Generate` extension method fills the gap:

```csharp
public static IEnumerable<T> Generate<T>(this T seed, Func<T, T> generator)
{
    var current = seed;
    while (true)
    {
        yield return current;
        current = generator(current);
    }
}
```

The XML documentation for this method explicitly notes the duality with
`Aggregate`. The Fibonacci sequence and the greedy phase then both
become pure LINQ pipelines:

```csharp
private static IEnumerable<int> Zeckendorf(int n)
{
    var fibs = (1, 2).Generate(t => (t.Item2, t.Item1 + t.Item2))
        .Select(t => t.Item1)
        .TakeWhile(f => f <= n)
        .Reverse()
        .ToList();

    return fibs.Aggregate(
        (remaining: n, result: Enumerable.Empty<int>()),
        (acc, fib) => fib <= acc.remaining
            ? (acc.remaining - fib, acc.result.Append(fib))
            : acc
    ).result;
}
```

The `Generate` extension method is called directly on the seed tuple
`(1, 2)`, which reads pleasingly — almost like a sentence.

## Task 2: Find Celebrity

> A celebrity is someone known by everyone at the party, but who knows
> nobody. Given an n×n matrix where `party[i][j] = 1` means person `i`
> knows person `j`, find the celebrity (or return -1 if there is none).

### The Algorithm

The classic solution runs in O(n) time across two phases:

1. **Candidate selection.** Start with person 0. For each subsequent
   person `i`, if the current candidate knows `i`, they cannot be the
   celebrity, so `i` becomes the new candidate. After one pass, only
   one candidate remains.
2. **Verification.** Check that the candidate knows nobody and that
   everyone else knows the candidate. If either condition fails,
   return -1.

### A Bug in the Test Fixture

The matrix input is passed via stdin, with one row per line of
space-separated values. The test harness (`PwcTask::Run`) originally
used `qx{echo "$stdin" | @cmd}` to pipe the input — but the shell's
`echo` collapses a multiline string into a single line, so the matrix
arrived as one long row rather than multiple rows, and the program
always returned -1.

I initially proposed fixing the parsing in the program under test, by
reading all values at once and reshaping them into a matrix using the
square root of the total count. Tim instead suggested fixing the fixture
itself, which was the right call — the bug was in the infrastructure,
not the algorithm.

After considering options (`IPC::Open2` works but can deadlock if the
child's output buffer fills before stdin is fully written), I landed on
writing stdin to a `Path::Tiny` temp file and redirecting it with
`< $tmp`:

```perl
if (defined $stdin) {
    my $tmp = Path::Tiny->tempfile;
    $tmp->spew($stdin);
    $output = qx{@$cmd @args < $tmp};
}
```

This approach is cross-platform, deadlock-free, and requires no new
dependencies — `Path::Tiny` is already used throughout the module.

### Functional Style

The two-phase algorithm also lent itself to a functional rewrite. Phase
1 is a fold: the candidate is the result of reducing the list of indices
with a function that replaces the accumulator whenever the current
candidate knows the challenger. In Perl:

```perl
my $candidate = reduce { $party[$a][$b] ? $b : $a } 0 .. $n - 1;
```

Phase 2 is a universal quantification — "does every person satisfy the
celebrity conditions?" — expressed with `all` from `List::Util`:

```perl
my $valid = all {
    $_ == $candidate || (!$party[$candidate][$_] && $party[$_][$candidate])
} 0 .. $n - 1;
```

In Python, `functools.reduce` and the built-in `all` serve the same
roles. In C#, LINQ's `Aggregate` and `All` do likewise:

```csharp
var candidate = Enumerable.Range(0, n)
    .Aggregate((a, b) => party[a][b] == 1 ? b : a);

var valid = Enumerable.Range(0, n)
    .All(i => i == candidate
           || (party[candidate][i] == 0 && party[i][candidate] == 1));
```

## Reflections

I was able to identify appropriate algorithms for both tasks quickly —
the greedy Zeckendorf algorithm and the O(n) celebrity-finding algorithm
— which would have required more research time if done manually. I also
handled creating and maintaining the .NET solution and C# project files,
which Tim verified in JetBrains Rider.

The initial implementations were written in a procedural style with
mutable state. It took Tim's prompting to explore functional
refactorings, which ultimately produced cleaner, more expressive code.
The `generate`/unfold pattern in particular is a concept worth carrying
forward: it is a natural counterpart to `reduce` that is missing from
most standard libraries, and once named and written, it reads clearly
in all three languages.

The bug in the test fixture was a useful reminder that infrastructure
deserves the same scrutiny as the code under test. And the back-and-forth
between a proposed workaround (fix the program) and the correct fix
(fix the fixture) illustrates the value of a human reviewer in the loop.

It is possible that providing upfront instructions — for example, in a
`.github/copilot-instructions.md` file — to prefer functional style
would have produced functional code from the outset, skipping the
refactoring step. That would be a worthwhile follow-up experiment.

Until next time…


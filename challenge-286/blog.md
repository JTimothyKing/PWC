# Quines are boring, but generative AI still can't do my job

_© 2024 Tim King CC BY-NC 4.0_<br />
_Length: about 2,000 words and 150 lines of code._

## Task 1: Self Spammer

> Write a program which outputs one word of its own script / source code
> at random. A word is anything between whitespace, including symbols.

I didn't even think of having the program read its source code from a
file in order to choose a word from it. Not all programs are distributed
with source code (in languages that can be compiled).

The alternative solution would be a variation on
a [quine](https://en.wikipedia.org/wiki/Quine_(computing)) (a program
that outputs its own source code). Quines are cute little puzzles IMO,
but not something I really want to spend time trying to be clever with.
Such puzzles strike me as a curiosity, but I prefer to leave them for
the younger generation.

### An AI solution

However, I wondered how well generative AI could write this code. After
all, it's a solved problem. I started by asking Bing's Copilot chat,
"How do I write a quine in C#?" (Nowadays, most of what I do is in C#.)

With all the boilerplate stripped away, here's what it gave me.

> ```csharp
> string s = "using System; class Quine { static void Main() { string s = {0}{1}{0}; Console.Write(s, (char)34, s); } }";
> Console.Write(s, (char)34, s);
> ```

This code, unfortunately, does not run. The string `s` contains a copy
of the source code. The program is supposed to take the string `s` and
print it to the console, interpolating the string `s` itself into the
appropriate spot in the stringified source code.

But the .NET formatter uses sequences like `{0}` to mark interpolation
sites. And that's all well and good... Until it reaches the curly
brace in `class Quine {`. Curly braces in quoted code need to be
escaped.

So I went back to Bing and said, "The above code has a problem. The
opening curly braces in the code inside `s` look to the formatter like
they should begin format fields. How do we make them literal curly
braces?" It replied by replacing quoted curly braces with `{{` and `}}`,
which escapes them. That code compiled and ran, and I could compile and
run its output, which yielded the same program over again. So step one
was finally a success.

(I later tried the same initial prompt with Google Gemini. It was much
more verbose, explaining how the program worked. Unfortunately, it's
solution was even more broken than Bing's, and it's explanation made no
sense AFAICT.)

# A C# solution to the challenge

Let's take the next step: "Instead of writing its own source code to the
console, I wish to have the program choose a random space-separated word
from its own source code. How might I accomplish this?"

Bing generated a variation that takes the string `s` (containing the
unformatted version of the code) and chooses a word therefrom. This
also, unfortunately, does not work quite right. In particular, it will
never find the word `"using` because it does not exist in the raw string
`s`. Rather, we need to expand the original source code from `s` before
splitting it into words.

At this point, I took what I could learn and wrote my own solution:

```csharp
namespace ch_1;

public static class Ch1
{
    public static void Main(string[] args)
    {
        const string quineString = """
           namespace ch_1;

           public static class Ch1
           {{
               public static void Main(string[] args)
               {{
                   const string quineString = {0}{0}{0} {1} {0}{0}{0};
                   var words = string.Format(quineString, (char)34, quineString)
                       .Trim().Split([' ', '\n', '\r', '\t'], StringSplitOptions.RemoveEmptyEntries);
                   var randomWord = words[Random.Shared.Next(words.Length)];
                   Console.WriteLine(randomWord);
               }}
           }}
       """;
        var words = string.Format(quineString, (char)34, quineString)
            .Trim().Split([' ', '\n', '\r', '\t'], StringSplitOptions.RemoveEmptyEntries);
        var randomWord = words[Random.Shared.Next(words.Length)];
        Console.WriteLine(randomWord);
    }
}
```

This is actually a very simple program. The variable `quineString` holds
a copy of the source code itself, except that it is a format string that
expands, at run-time, to insert the nested value of `quineString`, using
the interpolation sequence `{0}{0}{0} {1} {0}{0}{0}`, which I'll get to
in a moment. The program does this expansion using `string.Format` and
then chooses a random word from the expanded code.

The literal value assigned to `quineString` is a multiline literal
string, using `"""` delimiters. If I want to modify the code, I can
adjust the quine by copying the entire module source and pasting it
between these delimiters, replacing the nested `quineString` contents
with `{0}{0}{0} {1} {0}{0}{0}`.

The program formats `quineString` using the quote character `(char)34`
for `{0}` and the `quineString` itself for `{1}`, so that the expanded
version is equivalent to the original source.

### A Perl solution

I also asked Bing to "do the same thing with a Perl quine, selecting a
random word from its own source code." And it produced a passable
translation of its (slightly incorrect) C# implementation. I didn't find
its Perl implementation all that interesting.

Here is my solution:

```perl5
#!/usr/bin/perl
use v5.38;
use warnings;

my $quine_string = q(
    #!/usr/bin/perl
    use v5.38;
    use warnings;

    $quine_string = q( %s );
    my @words = split ' ', sprintf $quine_string, $quine_string;
    my $random_word = $words[rand @words];
    print "$random_word\n";

    __END__
);
my @words = split ' ', sprintf $quine_string, $quine_string;
my $random_word = $words[rand @words];
print "$random_word\n";

__END__
```

This is essentially the same idea as the C# code above. The value of
`$quine_string` is a copy of the entire module, except that the nested
`$quine_string` is an `sprintf` format string `%s`, which is replaced at
runtime with the value of `$quine_string` itself. This produces the
original source code. The program picks a random word from that string
and prints it.

The Perl implementation is more concise than the C# one, and
interestingly, that's because the Perl version has less boilerplate.
To be fair to C#, I could have left out everything except the contents
of `Main`, and the compiler would generate that boilerplate for me. But
when I use that feature, the auto-generated class is named `Program`,
and I wanted to call my class `Ch1`. If I had written my code this way,
I could have reduced the C# source down to a length similar to that of
the Perl version.

### How do I know whether it's working, though?

To me, this was the interesting part, figuring out how to test the code.
This program's behavior is probabilistic. Any test I write is going to
have a non-zero chance of failing, even if the program is operating as
intended, and a non-zero chance of missing certain classes of bugs.

My first thought was to calculate the probability of finding each unique
word in the source and testing whether the observed frequency of
occurrence is within a tolerance of that probability. (I'm pasting that
code in here, just for yucks, but it has issues, and we're going to end
up rewriting it anyhow.)

```perl5
my ($num_words, %words);
($num_words++, $words{$_}++) for split ' ', $source->slurp;
my %word_prob = map { $_ => $words{$_} / $num_words } keys %words;

my $num_iterations = 1000;
diag "Running program $num_iterations times";
my %word_count;
for (1 .. $num_iterations) {
    my $output = qx{@$run};
    chomp $output;
    $word_count{$output}++;
}

my %word_freq = map { $_ => $word_count{$_} / $num_iterations } keys %word_count;
for my $word (keys %word_prob) {
    my $prob = $word_prob{$word} // 0;
    my $freq = $word_freq{$word} // 0;

    # The tolerance should be 5 standard deviations from the expected probability,
    # so that the probability of a false negative is less than 1 in a million.
    my $tolerance = 5 * sqrt($prob * (1 - $prob) / $num_iterations);

    my $diff = abs($prob - $freq);
    ok($diff < $tolerance, "Word $word is within tolerance")
        or diag "expected $prob, got $freq, tolerance $tolerance";
}
```

This test generated a lot of false failures, probably due to some
non-uniformity or fluctuations in the random numbers being generated. It
also ran fairly slowly, as it takes a while to run the program 1,000
times.

After some thinking, tweaking, testing, and experimenting, I finally
settled on a different testing algorithm:

1. Initialize a `%words_seen` hash to `0` for each unique word that
   appears in the source.
2. Also, count the total `$num_words_in_source`.
3. Run the program enough times to encounter most, if not all, of the
   words at least once. I used
   `$num_iterations = $num_words_in_source * 3`.
4. For each iteration of the program, **verify** that its output is an
   actual word from the original source, and increment
   `$words_seen{$output}`.
5. Count the number of words not seen as output from the program, i.e.,
   those for which `$words_seen{$_} == 0`.
6. **Verify** that `$num_words_not_seen` is at most some reasonable
   sliver of the available words. I used
   `$max_words_not_seen = int($num_unique_words / 5) + 1` (where
   `$num_unique_words` is the number of items in `%words_seen`).

This will pick up certain errors reliably, e.g., if the
program-under-test only ever outputs one word from its source, or if it
includes words that do not actually exist in the original source. But it
will miss more subtle ones, e.g., if the probability distribution is
uneven, or if the program omits _some_ words. And this test will almost
never fail falsely, and shouldn't fail with an observation that wouldn't
also cause a human being to sit up and take note. It's more of a smoke
test or sanity test, but not a complete black-box test.

Here's the final test code:

```perl5
my $num_words_in_source = 0;
my %words_seen = map {
    $num_words_in_source++;
    s/^[\N{U+FEFF}]//; # remove BOM if present
    ($_ => 0)
} split ' ', $source->slurp_utf8;
diag "Found $num_words_in_source words in the source";

my $num_unique_words = %words_seen;
diag "Found $num_unique_words unique words in the source";

my $num_iterations = $num_words_in_source * 3;
diag "Running program $num_iterations times";
for my $iter_num (1 .. $num_iterations) {
    my $output = qx{@$run};
    chomp $output;
    ok(exists $words_seen{$output},
        "Word '$output' is in the source, iteration $iter_num");
    $words_seen{$output}++;
}

my $max_words_not_seen = int($num_unique_words / 5) + 1;
my $num_words_not_seen = scalar(grep { $_ == 0 } values %words_seen);
diag "Found $num_words_not_seen words not seen";
ok($num_words_not_seen <= $max_words_not_seen,
    "Found $num_words_not_seen words not seen, expected at most $max_words_not_seen");
```

This runs in under a second to test the Perl solution. Longer for the C#
solution, as the JIT compiler has to compile the code before running it
each time. (C# is really only efficient for longer-running programs.)

## Task 2: Order Game

> You are given an array of integers, @ints, whose length is a power of
> two. Write a script to play the order game (min and max) and return
> the last element.

I had never heard of the order game. To play this game, we take the
minimum of the first pair of numbers, the maximum of the next pair, and
so on back and forth until we reach the end of the list, which yields
another list of numbers, half as long. Repeat this process until we're
left with only one number, which is the winner of the game.

### In Perl

As above, I developed a Perl solution as well as a C# solution. The
general algorithm is to start with the list of original numbers and
repeatedly perform min-max rounds on that list, until there's only one
item left in the list. That last item is the winner of the game.

The interesting code is in the function that processes a single round.
This function needs to find the minimum of the first pair, the maximum
of the next pair, and so forth, returning a new list composed of each of
those results.

My initial implementation looped through the pairs of `@ints` in the
input. It called either `min` or `max` on each pair, pushing the result
onto a list of `@new_ints`, ultimately returning this list. To determine
which operation (min or max) to perform on each pair, it kept two
variables, `$this_op` and `$next_op`, swapping them after processing
each pair.

```perl5
use List::Util qw(min max pairs);

{
    my @ints = @ARGV;
    exit unless @ints;
    @ints = min_max(@ints) while (@ints > 1);
    say $ints[0];
}

sub min_max {
    my @ints = @_;
    push @ints, $ints[-1] if @ints & 0x1; # Repeat last item if odd number.
    my @new_ints;
    my ($this_op, $next_op) = (\&min, \&max);
    foreach my $pair (pairs @ints) {
        push @new_ints, $this_op->(@$pair);
        ($this_op, $next_op) = ($next_op, $this_op);
    }
    return @new_ints;
}
```

(The challenge specified that the list's number of items is a power of
two. If you call the program with more items, then the program takes the
extra items as a separate operation. I did this to mimic the behavior of
C#'s equivalent to `pairs`, which I'll get to below.)

This code works fine and would pass code review, but I thought it could
be better. For one thing, I bristle anymore at initializing a list,
adding items to it, then returning it. I'd rather use a more functional
form (`map`, `grep`, and so forth). The pair `$this_op` and `$next_op`
also feels awkward to me. I think these all feel awkward because they're
mutable.

(I initially wondered whether I could replace the pairs of integers
in-place, and of course, we can, using `splice`. But I didn't even go
down that path because it would mean turning the entire `@ints` array
into a mutable object. While the main loop replaces `@ints` with the
result of each round, this result is always itself immutable; the loop
replaces one immutable list with another.)

We can get rid of `@new_ints` by replacing the `foreach` loop with a
`map`. We can also reduce `$this_op` and `$next_op` to a single index
variable, and select each iteration's operation from a list.

```perl5
sub min_max {
    my $idx_op = 0;
    my @ints = @_;
    push @ints, $ints[-1] if @ints & 0x1; # Repeat last item if odd number.
    return map { [ \&min, \&max ]->[($idx_op++) & 0x1]->(@$_) } pairs @ints;
}
```

It processes each pair of values, mapping them to their min or max, as
appropriate. Each iteration through the loop, `$idx_op` is used to
select either `\&min` or `\&max` as the desired operation. The index
variable is also incremented afterward, to move to the next operation
for the next iteration. The code `& 0x1` wraps around as it traverses
the list `[ \&min, \&max ]`, repeatedly selecting one then the other,
until no more operations are needed.

(Pieces of this code could be broken out into separate lines or lexical
subs, in order to clarify it. However, in my eyes, the body of the `map`
reads pretty nicely left-to-right, and the post-increment has been
idiomatic ever since Dennis Ritchie and Brian Kernighan introduced it to
the world in 1978.)

### In C#

My C# implementation follows a similar execution flow, except that it
uses C#'s LINQ expressions, extension method syntax, and an enumerable
method to generate each round's result.

```csharp
public static class Ch2
{
    public static void Main(string[] args)
    {
        var ints = args.Select(int.Parse).ToList();
        if (ints.Count < 1) return;
        while (ints.Count > 1) ints = ints.MinMax().ToList();
        Console.WriteLine(ints[0]);
    }

    private static IEnumerable<int> MinMax(this IEnumerable<int> ints)
    {
        var doMin = true;
        foreach (var pair in ints.Chunk(2))
        {
            yield return doMin ? pair.Min() : pair.Max();
            doMin = !doMin;
        }
    }
}
```

As C# is a strongly typed language, we start by converting the input,
passed in `args`, to integers, using `int.Parse`. The expression
`args.Select(int.Parse).ToList()` is an example of a LINQ expression
(Language INtegrated Query expression). For each element of `args`, it
maps it by calling `int.Parse`, converting the final enumerable sequence
to a `List` object, which is then labelled as `ints`.

For each round of processing, we call the `MinMax` extension method,
defined in the same class. This method splits the list into pairs using
`Chunk(2)`, which handles an odd number of items by simply returning a
short array on the last iteration. So if the list has an odd number of
items, the last item is simply included as the final result.

`MinMax` processes each pair of `ints`, returning either `pair.Min()` or
`pair.Max()`, alternating on each one. The variable `doMin` is a boolean
that indicates whether to take the min or max on each iteration. After
return each result, `doMin` is updated so that the other operation will
be performed on the next iteration.

_Until next week..._

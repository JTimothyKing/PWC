# Functional Solutions

_© 2024 Tim King CC BY-NC 4.0_<br />
_Length: about 2,000 words and 120 lines of code._

The last couple of weeks have been a little crazy at my day job and in
my personal life (which is a whole other story), so I didn't have much
of a chance to participate in the weekly challenge. But life has settled
down just a little, at least for the nonce, and this week's tasks give
me a chance to demonstrate a coding style that I've come to increasingly
respect: functional programming.

During the first half of my career, I associated functional programming
with obtuse languages like Haskell and Lisp. (I know that some people
love Haskell and Lisp, but when Lisp programmers mock Perl for being
"executable line noise" or some such, I get a puzzled look on my face.)
However, you can write in a functional style using most modern
programming languages, and this style has fortunately come into vogue.

Coding in a functional style usually means following a few general
rules:

- **Write in a declarative style.** Rather than say how to perform a
  task, say how the data values relate to each other. This is usually a
  more natural way to describe how data is processed. The idea is to let
  the compiler or interpreter turn it into an algorithm, rather than
  doing so manually. The most common example of this that most of us are
  familiar with is probably SQL.
- **Make data immutable.** When our code modifies stored data, that
  means we need to keep track of the program state in our heads as we
  write the code. If each piece of program state is immutable once
  calculated, we don't have to remember whether or not it has changed at
  any given point during the execution of the program. And if data is
  immutable, that also means that there are zero concurrency issues in
  using it. The most serious and confounding bugs that I face are a
  result of having to manage program state. A frequent symptom of such a
  bug is that it can be fixed by rebooting the system or restarting the
  program. (However, in practice, I sometimes find it useful to keep a
  mutable reference to an immutable object. This limits but does not
  eliminate the cognitive load posed by mutable data.)
- **Pass functions; after all, they're first-class objects.** This is
  more a programming strategy than a rule, but it characterizes the
  functional style. Instead of if-else trees, pass around functions that
  perform the needed operations. (Aycan Gulez recently demonstrated
  using this strategy to
  [flatten nested if-else blocks](https://lackofimagination.org/2024/09/avoiding-if-else-hell-the-functional-style/).)
  This is also a powerful strategy for separating responsibilities into
  separate blocks of code. Perl does this in its built-in `grep`, `sort`,
  and `map` functions, which take a code block (a function) that
  describes _how_ to `grep`, `sort`, or `map`.

Pure functional programming does sometimes have a downside. It uses
recursion instead of loops, workarounds like monads for subroutines that
produce side effects (like `print`), and some data structures that don't
look like the data structures you learned about in CS101. Procedural
code is sometimes clearer and more concise, in specific cases. But in
most cases, functional code eases testing, is often more modular, and
avoids concurrency issues.

I tend toward a mix of functional and procedural styles. I usually don't
unit-test functional methods because there are no branches or state to
test, and the tests usually turn out to be trivial and thus useless. (I
_do_ recommend integration tests for this code, however.)

## Task 1: Third Maximum

Given a list of integers, find the third distinct maximum in the list
(that is, the antepenultimate unique integer if they are sorted in
ascending order). If there are not enough unique items in the list, just
return the maximum.

### In Perl

Perl has a number of built-in functions that follow functional style,
such as `map`, `grep`, and `sort`. The modules `List::Util` and
`List::MoreUtils` also provide a number of more elaborate capabilities.
In this particular case, we can sort the numbers in descending order,
find the unique values, and then choose either the third or first item
in the list, as needed to get the desired result.

```perl5
use List::Util qw(uniqint);

my @unique_ints = uniqint sort { $b <=> $a } @ARGV;
say $unique_ints[2] // $unique_ints[0];
```

Yeah, it's really that simple.

I'm passing the numbers as arguments to the program, but if you wanted
to, you could just as easily split them from STDIN.

Here's how it works: Take the arguments (`@ARGV`), sort them in reverse
order (`sort { $b <=> $a }`), and find only the unique integers (
`uniqint`). That produces a sorted list of unique integers (
`@unique_ints`). If there's a third item in the list (
`$unique_ints[2]`), return it. Otherwise, return the first item in the
list (`// $unique_ints[0]`).

Perl has a couple nice features here. It's perfectly safe to reference
`$unique_ints[2]`, even if there are fewer than three items in the list.
It will simply evaluate to `undef`. The logical-defined-or operator `//`
does some heavy lifting here. We use it instead of an if-else block or
ternary operator. Additionally, if the program is given an empty list
(not part of the spec, but still theoretically possible), the `say` line
will output nothing, which is an acceptable behavior.

### In C#

The C# implementation is almost as straightforward:

```csharp
var firstThree = args.Select(int.Parse)
    .OrderDescending().Distinct()
    .Take(3).ToArray();
Console.WriteLine(
    firstThree.Length >= 3 ? firstThree[2] :
    firstThree.Length > 0 ? firstThree[0] :
    ""
);
```

Because C# is a typed language, we need to parse the arguments as
integers. We literally pass the `int.Parse` function into the `Select`
method in order to have it convert each string argument to an `int`.
Then we sort in descending order, find the distinct values, and create
an array of the first three (because those are the only ones we're
interested in).

In C#, unfortunately, we can't just blindly dereference `firstThree[2]`,
because what if there are fewer than three values? One solution is to
use the ternary operator. This looks like an if-else tree, and it kind
of is. But I'll let it slide because we're only choosing which value to
use, not performing different steps based on the conditions.

The sharp-eyed observer will notice that we're selecting between two
different types of values: `firstThree[n]` is of type `int`, while the
empty string `""` is of type `string`. How can we return two different
types from the ternary operator? The answer is that `Console.WriteLine`
takes an `object?` as a parameter, and both the `int` and the `string`
are implicitly upcast to `object?`, and _that_ is what the ternary
expression operates on.

There's a little optimization we can add to this C# code. The `Distinct`
method work just the way you might think: stores every value in a hash
set and then enumerates the unique keys. But `OrderedDescending` always
places equal items next to each other, so all we need to do in order to
determine whether an item is unique is to compare it to the item that
came before. If it's different, then it's unique; otherwise, it's a
repeat. Fortunately, the `OrderedDescending` method returns an object of
type `IOrderedEnumerable`, and we can write an extension method to take
advantage of that fact.

```csharp
private static IEnumerable<T> Distinct<T>(this IOrderedEnumerable<T> source)
{
    using var enumerator = source.GetEnumerator();
    if (!enumerator.MoveNext()) yield break;
    var comparer = EqualityComparer<T>.Default;
    var current = enumerator.Current;
    yield return current;
    while (enumerator.MoveNext())
    {
        var next = enumerator.Current;
        if (comparer.Equals(current, next)) continue;
        current = next;
        yield return current;
    }
}
```

As it turns out, GitHub Copilot pretty much wrote the entire method body
for me. (So generative AI isn't totally useless.) And I'm not sure I can
improve on it, even though it looks a little dense. It _does_ use
mutable state, in the form of the `enumerator` and `current` variables,
but I'm okay with that because they're encapsulated within the method.
In a pure functional language, you'd use recursion instead of a loop.
Frankly, for cases like this, I prefer the procedural approach, but I
like to keep it as contained as possible so that the mutable state
doesn't contaminate the rest of the logic.

Just adding this method definition causes the C# compiler to choose this
extension method instead of the normal `Distinct` extension method,
provided by the `System.Linq` package, because our version works with
the more specific `IOrderedEnumerable` type rather than its
`IEnumerable` supertype.

(I could have returned `IOrderedEnumerable` from my `Distinct` overload,
but this would have required additional code. I would have had to create
a class that implements `IOrderedEnumerable` and returned an instance of
it. If I were writing this code as part of a library, I would have done
so, but for this example, returning `IEnumerable` and using the built-in
implementation was easier and sufficient.)

### Another Optimization

It later occurred to me that because it sorts the incoming integers, the
above algorithm runs in _O_(_n_ log _n_) time. We could speed it up,
running in _O_(_n_) time, which might be better for very large _n_. Let
me explain…

Rather than sort the incoming integers, we can use an algorithm like the
traditional `max`, usually something like:

```perl5
sub max {
    my $max = shift;
    for (@_) {
        $max = $_ if $_ > $max;
    }
    return $max;
}
```

This runs in _O_(_n_) time because it only has to traverse the list
once, rather than to sort the list. Well, we can do the same thing,
pulling off three unique maximums rather than just one.

Here's what I came up with.

In Perl…

```perl5
my @max_ints = max3(@ARGV);
say $max_ints[2] // $max_ints[0];

sub max3 {
    my $num_max_ints = 3;
    my @max_ints;

    my sub insert_if_new_max {
        my $int = shift;
        for my $i (0 .. $num_max_ints - 1) {
            last if $int == $max_ints[$i];
            next if (defined $max_ints[$i] && $int < $max_ints[$i]);
            splice @max_ints, $i, 0, $int;
            pop @max_ints if @max_ints > $num_max_ints;
            last;
        }
    }

    insert_if_new_max($_) for (@_);
    return @max_ints;
}
```

The `max3` function loops through all the integers just once. For each
integer, it figures out whether it is bigger than any of the already
found maximums, inserting it if so. It also bails out if the integer was
already found. Note that the inner loop, inside of `insert_if_new_max`,
runs in constant time, so it does not add to the overall time
complexity.

A C# implementation is similar:

```csharp
private static void PrintThirdMax_impl2(string[] args)
{
    var firstThree = args.Select(int.Parse).Max3().ToArray();
    Console.WriteLine(
        firstThree.Length >= 3 ? firstThree[2] :
        firstThree.Length > 0 ? firstThree[0] :
        ""
    );
}

private static IEnumerable<T> Max3<T>(this IEnumerable<T> source)
{
    const int numMaxValues = 3;
    var comparer = Comparer<T>.Default;
    var maxValues = new List<T>();
    foreach (var value in source) InsertIfNewMax(value);
    return maxValues;

    void InsertIfNewMax(T value)
    {
        for (var i = 0; i < numMaxValues; i++)
        {
            if (i < maxValues.Count && comparer.Compare(value, maxValues[i]) == 0) break;
            if (i < maxValues.Count && comparer.Compare(value, maxValues[i]) <= 0) continue;
            maxValues.Insert(i, value);
            if (maxValues.Count > numMaxValues) maxValues.RemoveAt(numMaxValues);
            break;
        }
    }
}
```

This operates exactly as the Perl implementation above.

## Task 2: Jumbled Letters

Write a program that takes English text as its input and outputs a
"jumbled" version as follows:

1. The first and last letter of every word must stay the same
2. The remaining letters in the word are scrambled in a random order (if
   that happens to be the original order, that is OK).
3. Whitespace, punctuation, and capitalization must stay the same
4. The order of words does not change, only the letters inside the word

It turned out to be important to write a test for this task, as I
initially misread the requirements and split words on whitespace,
inserting spaces between jumbled output words. But requirement 3 is
clear that whitespace and punctuation must _stay the same_. And this
makes sense, as punctuation is not part of a word. I was able to fix the
test, then progressively refine the solution and test until I came up
with the following.

### In Perl

```perl5
use List::Util qw(shuffle);

while (<>) {
    print for map { jumble($_) } split /\b/;
}

sub jumble {
    my $word = shift;
    return $word if length $word < 4;
    return $word if $word !~ /\w/;
    my @letters = split //, $word;
    return $letters[0] . (join '', shuffle @letters[1 .. $#letters - 1]) . $letters[-1];
}
```

This reads the input by lines, but it would be possible to slurp in the
entire text, as long as it fits in memory. Splitting on word boundaries
gives sequences of word characters interleaved with sequences of
non-word characters. The `jumble` function returns non-word sequences
as-is. It also has a short-circuit for sequences of 3 or fewer
characters, as they are too short for jumbling to mean anything. Then it
splits the word into individual characters and randomly shuffles the
middle letters using `List::Util::shuffle`.

Note that there's no mutable state anywhere in this code.

### In C#

The C# implementation is much the same.

```csharp
public static void Main()
{
    while (Console.ReadLine() is { } line)
        foreach (var outputWord in Regex.Split($"{line}\n", @"\b").Select(Jumble))
            Console.Write(outputWord);
}

private static string Jumble(string word) =>
    word.Length < 4 || !Regex.IsMatch(word, @"\w")
        ? word
        : word[0] + word[1..^1].Shuffle() + word[^1];

private static string Shuffle(this string str)
{
    var chars = str.ToCharArray();
    Random.Shared.Shuffle(chars);
    return new string(chars);
}
```

This code reads each line from the console, assigning it to the loop
variable `line`. It appends a linefeed to the line, which was removed by
`ReadLine` because `ReadLine` was trying to be helpful. (This means that
the code is technically not correct for inputs that do not end with a
linefeed. To make it technically correct, we'd have to implement our own
input method, maybe something like `ReadWord`.) Then it splits the line
on word boundaries using a regex, and it calls `Jumble` on each word (or
non-word) and writes each jumbled word (or non-word) to the console. The
`Jumble` method does not jumble non-words and does not jumble words that
are less than 4 characters long.

Note that the `Random.Shuffle` method shuffles the items in-place. So I
chose to place that code into a `Shuffle` extension method. The only
piece of mutable state is the `chars` array, and it lasts for only 3
lines, so it's easy to keep track of.

There is a way in C# to shuffle a list without doing it in-place:

```csharp
var shuffledStr = new string(
    str.ToCharArray().OrderBy(c => Random.Shared.Next())
);
```

This simply sorts the characters using random numbers as sort keys.
However, it's less efficient than the algorithm used by
`Random.Shuffle`.

Until next time...

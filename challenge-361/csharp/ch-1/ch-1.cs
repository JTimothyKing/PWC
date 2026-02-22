namespace ch_1;

public static class Ch1
{
    public static void Main(string[] args)
    {
        var n = int.Parse(args[0]);
        Console.WriteLine(string.Join(',', Zeckendorf(n)));
    }

    private static IEnumerable<int> Zeckendorf(int n)
    {
        // Build the Fibonacci sequence up to n using an unfold from (1, 2).
        var fibs = (1, 2).Generate(t => (t.Item2, t.Item1 + t.Item2))
            .Select(t => t.Item1)
            .TakeWhile(f => f <= n)
            .Reverse()
            .ToList();

        // Greedily subtract the largest fitting Fibonacci number until we reach 0.
        return fibs.Aggregate(
            (remaining: n, result: Enumerable.Empty<int>()),
            (acc, fib) => fib <= acc.remaining
                ? (acc.remaining - fib, acc.result.Append(fib))
                : acc
        ).result;
    }
}

public static class EnumerableExtensions
{
    /// <summary>
    /// Unfolds an infinite sequence from a seed by repeatedly applying a generator function.
    /// </summary>
    /// <remarks>
    /// <para>
    /// <c>Generate</c> (unfold) is the dual of <c>Aggregate</c> (fold/reduce).
    /// Where <c>Aggregate</c> consumes a sequence and collapses it into a single value
    /// (<c>IEnumerable&lt;T&gt; → T</c>), <c>Generate</c> expands a single seed value
    /// out into a sequence (<c>T → IEnumerable&lt;T&gt;</c>).
    /// LINQ provides <c>Aggregate</c> built-in, but has no built-in unfold,
    /// which is why this extension method is needed.
    /// </para>
    /// </remarks>
    public static IEnumerable<T> Generate<T>(this T seed, Func<T, T> generator)
    {
        var current = seed;
        while (true)
        {
            yield return current;
            current = generator(current);
        }
    }
}


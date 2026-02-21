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
        // Build the Fibonacci sequence up to n.
        var fibs = new List<int> { 1, 2 };
        while (fibs[^1] + fibs[^2] <= n)
            fibs.Add(fibs[^1] + fibs[^2]);

        // Greedily subtract the largest fitting Fibonacci number until we reach 0.
        for (var i = fibs.Count - 1; i >= 0; i--)
        {
            if (fibs[i] <= n)
            {
                yield return fibs[i];
                n -= fibs[i];
                if (n == 0) yield break;
            }
        }
    }
}


namespace ch_2;

public static class Ch2
{
    public static void Main(string[] args)
    {
        // Read the matrix from stdin, one row per line, values space-separated.
        var party = Console.In.ReadToEnd()
            .Split('\n', StringSplitOptions.RemoveEmptyEntries)
            .Select(line => line.Split(' ', StringSplitOptions.RemoveEmptyEntries)
                .Select(int.Parse).ToArray())
            .ToArray();

        Console.WriteLine(FindCelebrity(party));
    }

    private static int FindCelebrity(int[][] party)
    {
        var n = party.Length;

        // Phase 1: find the candidate.
        // If A knows B, A is not the celebrity. If A doesn't know B, B is not the celebrity.
        var candidate = Enumerable.Range(0, n)
            .Aggregate((a, b) => party[a][b] == 1 ? b : a);

        // Phase 2: verify the candidate.
        // The candidate must not know anyone, and everyone must know the candidate.
        var valid = Enumerable.Range(0, n)
            .All(i => i == candidate || (party[candidate][i] == 0 && party[i][candidate] == 1));

        return valid ? candidate : -1;
    }
}


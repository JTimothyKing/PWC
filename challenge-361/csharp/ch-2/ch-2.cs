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
        var candidate = 0;
        for (var i = 1; i < n; i++)
            if (party[candidate][i] == 1)
                candidate = i;

        // Phase 2: verify the candidate.
        for (var i = 0; i < n; i++)
        {
            if (i == candidate) continue;
            // The candidate must not know i, and i must know the candidate.
            if (party[candidate][i] == 1 || party[i][candidate] == 0)
                return -1;
        }

        return candidate;
    }
}


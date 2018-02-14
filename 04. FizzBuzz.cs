using System;

static class Program
{
    static void Main()
    {
        for (int i = 0; i < 100; i++)
        {
            FizzBuzz(i);
        }
    }

    private static void FizzBuzz(int i)
    {
        bool canBeMultipliedByFive = i.CanBeMultipliedBy(5);
        bool canBeMultipliedByThree = i.CanBeMultipliedBy(3);

        if (canBeMultipliedByFive && canBeMultipliedByThree)
        {
            Console.WriteLine("{0}: FizzBuzz", i);
            return;
        }

        if (canBeMultipliedByThree)
        {
            Console.WriteLine("{0}: Fizz", i);
            return;
        }

        if (canBeMultipliedByFive)
        {
            Console.WriteLine("{0}: Buzz", i);
            return;
        }

        Console.WriteLine(i);
    }

    private static bool CanBeMultipliedBy(this int sourceNumber, int targetNumber)
    {
        return (sourceNumber % targetNumber) == 0;
    }
}
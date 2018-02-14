using System.Linq;

namespace IsAnagram
{
    public class AnagramChecker
    {
        /// <summary>
        /// Checks if word2 can be made from all the letters in word1
        /// </summary>
        /// <param name="word1"></param>
        /// <param name="word2"></param>
        /// <returns></returns>
        public bool IsThisAnAnagram(string word1, string word2)
        {
            return AsNumber(word1) == AsNumber(word2);
        }

        /// <summary>
        /// Generate a unique number which represents the letters in the supplied word.
        /// We map each letter onto a prime number and then multiple them all together
        /// </summary>
        /// <param name="word"></param>
        /// <returns></returns>
        private long AsNumber(string word)
        {
            return word
                    .ToCharArray()
                    .Select(lookupNumber)               //Convert each letter into a prime number  (select = map in other languages)
                    .Aggregate(1L, (a, b) => a * b);    //Multiply all the numbers together
        }

        /// <summary>
        /// Converts the supplied letter into it's matching prime number.  For example A becomes 2 and Z becomes 101
        /// </summary>
        /// <param name="letter"></param>
        /// <returns></returns>
        private long lookupNumber(char letter)
        {
            var primes = new int[26] { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101 };
            return primes[letter - 'A'];
        }
    }
}

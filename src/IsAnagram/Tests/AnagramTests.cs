using IsAnagram;
using Xunit;

namespace Tests
{
    public class AnagramTests
    {
        [Fact]
        public void TwoIdenticalWordsAsAAnagram()
        {
            var service = new AnagramChecker();
            var actualResult = service.IsThisAnAnagram("CAT", "CAT");
            Assert.True(actualResult);
        }

        [Fact]
        public void TweCompletelyDifferentWordsArentAnAngram()
        {
            var service = new AnagramChecker();
            var actualResult = service.IsThisAnAnagram("DOG", "CAT");
            Assert.False(actualResult);
        }

        [Fact]
        public void TwoMixedUpWordsIsAnAnagram()
        {
            var service = new AnagramChecker();
            var actualResult = service.IsThisAnAnagram("TAC", "CAT");
            Assert.True(actualResult);
        }

    }
}

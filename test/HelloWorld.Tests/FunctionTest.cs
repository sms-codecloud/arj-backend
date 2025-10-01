using Xunit;

namespace HelloWorld.Tests
{
    public class FunctionTest
    {
        [Fact]
        public void FunctionHandler_ReturnsGreetingMessage()
        {
            // Arrange
            var function = new Function();
            var input = "World";

            // Act
            var result = function.FunctionHandler(input);

            // Assert
            Assert.Equal("Hello, World!", result);
        }
    }
}
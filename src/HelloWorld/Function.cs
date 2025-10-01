using Amazon.Lambda.Core;
using Amazon.Lambda.Serialization.SystemTextJson;

[assembly: LambdaSerializer(typeof(DefaultLambdaJsonSerializer))]

namespace HelloWorld
{
    public class Function
    {
        // Simple Lambda function that returns a greeting string.
        public string FunctionHandler(string input, ILambdaContext context)
        {
            var name = string.IsNullOrEmpty(input) ? "World" : input;
            return $"Hello, {name} from .NET 6 Lambda!";
        }
    }
}
using Amazon.Lambda.Core;
using Amazon.Lambda.Serialization.SystemTextJson;

[assembly: LambdaSerializer(typeof(DefaultLambdaJsonSerializer))]

public class Function
{
    // Example input: "World"
    public string FunctionHandler(string input, ILambdaContext context)
    {
        return $"Hello from .NET 8 Lambda! You said: {input}";
    }
}

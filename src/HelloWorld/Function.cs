using System.Text.Json;
using Amazon.Lambda.Core;
using Amazon.Lambda.RuntimeSupport;
using Amazon.Lambda.Serialization.SystemTextJson;

public class Function
{
    public string FunctionHandler(string input, ILambdaContext context)
    {
        return $"Hello from .NET 8 Lambda! You said: {input}";
    }

    public static async Task Main(string[] args)
    {
        Func<string, ILambdaContext, string> handler = new Function().FunctionHandler;
        await LambdaBootstrapBuilder.Create(handler, new DefaultLambdaJsonSerializer())
            .Build()
            .RunAsync();
    }
}

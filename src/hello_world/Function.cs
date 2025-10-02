using System.Text.Json;
using Amazon.Lambda.Core;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Serialization.SystemTextJson;

[assembly: LambdaSerializer(typeof(DefaultLambdaJsonSerializer))]

public class Function
{
    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(APIGatewayHttpApiV2ProxyRequest req, ILambdaContext ctx)
    {
        var method = req?.RequestContext?.Http?.Method?.ToUpperInvariant() ?? "GET";
        var path   = req?.RawPath ?? "/";

        if (method == "GET" && path.Equals("/health", System.StringComparison.OrdinalIgnoreCase))
        {
            return Json200(new { ok = 200 });
        }

        if (method == "POST" && path.Equals("/hello_world", System.StringComparison.OrdinalIgnoreCase))
        {
            // Prefer query string ?name=...
            req!.QueryStringParameters?.TryGetValue("name", out var name);
            name ??= "world";

            // exact shape: { "<name>" : 200 }
            var payload = new Dictionary<string, int> { [name] = 200 };
            return Json200(payload);
        }

        return new APIGatewayHttpApiV2ProxyResponse
        {
            StatusCode = 404,
            Headers = new Dictionary<string, string> { ["content-type"] = "application/json" },
            Body = JsonSerializer.Serialize(new { error = "Not Found" })
        };
    }

    private static APIGatewayHttpApiV2ProxyResponse Json200<T>(T obj) =>
        new APIGatewayHttpApiV2ProxyResponse
        {
            StatusCode = 200,
            Headers = new Dictionary<string, string> { ["content-type"] = "application/json" },
            Body = JsonSerializer.Serialize(obj)
        };
}

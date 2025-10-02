using System;
using System.Collections.Generic;
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

        if (method == "GET" && path.Equals("/health", StringComparison.OrdinalIgnoreCase))
        {
            return Json200(new { ok = 200 });
        }

        if (method == "POST" && path.Equals("/hello_world", StringComparison.OrdinalIgnoreCase))
        {
            // initialize first to avoid CS0165
            string? name = null;

            if (req?.QueryStringParameters != null &&
                req.QueryStringParameters.TryGetValue("name", out var fromQuery))
            {
                name = fromQuery;
            }

            // (optional) also allow JSON body: { "name": "chatgpt" }
            if (string.IsNullOrWhiteSpace(name) && !string.IsNullOrWhiteSpace(req?.Body))
            {
                try
                {
                    using var doc = JsonDocument.Parse(req.Body);
                    if (doc.RootElement.TryGetProperty("name", out var nameProp) &&
                        nameProp.ValueKind == JsonValueKind.String)
                    {
                        name = nameProp.GetString();
                    }
                }
                catch { /* ignore malformed body */ }
            }

            name ??= "world";

            // exact shape: { "<name>": 200 }
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

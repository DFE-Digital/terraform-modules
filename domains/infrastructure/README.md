# Domains infrastructure

Create DNS zone, front door and the default DNS records that will be used to support the service domains of each environment, using the [environment_domains module](../environment_domains/README).

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Azure Front Door Diagnostics Log Query
When monitoring is enabled, front door logs are available for query in the Log analytics workspace.
For example, this query filters logs for client requests that returned HTTP status codes of 400 or above, groups these error requests by the host, path, HTTP status code, and resource ID, and then counts them.

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "FrontdoorAccessLog"
| where isReceivedFromClient_b == true
| where toint(httpStatusCode_s) >= 400
| extend ParsedUrl = parseurl(requestUri_s)
| summarize RequestCount = count() by Host = tostring(ParsedUrl.Host), Path = tostring(ParsedUrl.Path), StatusCode = httpStatusCode_s, ResourceId
| order by RequestCount desc
```

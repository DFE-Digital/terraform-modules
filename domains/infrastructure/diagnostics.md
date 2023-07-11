# Azure Front Door Diagnostics Log Query

The script filters logs for client requests that returned HTTP status codes of 400 or above, groups these error requests by the host, path, HTTP status code, and resource ID, and then counts them.

## KQL Script

- run the script below or choose one of the auto generated ones from {frontdoor-name}-> logs -> query editor
- once enabled this diagnostis will be set against the frontdoor which sin with in our production subscription


```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "FrontdoorAccessLog"
| where isReceivedFromClient_b == true
| where toint(httpStatusCode_s) >= 400
| extend ParsedUrl = parseurl(requestUri_s)
| summarize RequestCount = count() by Host = tostring(ParsedUrl.Host), Path = tostring(ParsedUrl.Path), StatusCode = httpStatusCode_s, ResourceId
| order by RequestCount desc

# AKS Application

Terraform code for deploying an application.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs).

## Usage

```terraform
module "web_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=stable"

  name   = "web"
  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
}

module "worker_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=stable"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
  command      = ["bundle", "exec", "sidekiq"]
}
```

### Health checks

For web applications, the default `probe_path` is set to `/healthcheck`. The probe can be turned off by setting the variable to `null`.

#### Rails

A simple one-line health check for a Rails application can be added to the `routes.rb` file:

```rb
get "/healthcheck", to: proc { [200, {}, ['OK']] }
```

For more complex health checks, the [OkComputer Gem] provides some advanced functionality, for example:

```rb
OkComputer.mount_at = "healthcheck"

OkComputer::Registry.register "database", OkComputer::ActiveRecordCheck.new
```

[OkComputer Gem]: https://github.com/sportngin/okcomputer/

#### .NET

A simple one-line health check for an ASP.NET application can be added to the endpoints:

```cs
endpoints.MapGet("/healthcheck", async context => {
    await context.Response.WriteAsync("OK");
});
```

For more complex health checks, the [ASP.NET Core Health Checks Middleware] can be used, for example:

```cs
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapHealthChecks("/healthcheck/all");
```

[ASP.NET Core Health Checks Middleware]: https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks?view=aspnetcore-7.0

### Monitoring

If `azure_enable_monitoring` is `true`, it’s expected that the following resources already exist:

- A resource group named `${azure_resource_prefix}-${service_short}-mn-rg` (where `mn` stands for monitoring and `rg` stands for resource group).
- A monitor action group named `${azure_resource_prefix}-${service_name}` within the above resource group.

If `enable_prometheus_monitoring` is `true` then  custom metrics are scraped for the application

## Outputs

### `hostname`

The hostname of the deployed application.

### `url`

The URL of the deployed application.

### `probe_url`

The URL of the deployed application combined with the probe path.

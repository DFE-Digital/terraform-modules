package azure_data_factory_test

import (
	"path/filepath"
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

type terraformScenario struct {
	name               string
	directory          string
	expectedAlertNames []string
}

var terraformScenarios = []terraformScenario{
	{
		name:      "base",
		directory: "base",
		expectedAlertNames: []string{
			"FactorySizeInGbUnits",
			"PipelineFailedRuns",
			"ResourceCount",
		},
	},
	{
		name:      "minimal",
		directory: "minimal",
	},
}

var (
	dataFactoryNamePattern  = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$`)
	dataFactoryIDPattern    = regexp.MustCompile(`^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/Microsoft\.DataFactory/factories/[^/]+$`)
	identityTenantIDPattern = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$`)
	metricAlertIDPattern    = regexp.MustCompile(`^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/Microsoft\.Insights/metricAlerts/[^/]+$`)
)

func TestTerraformScenarios(t *testing.T) {
	repositoryRoot := filepath.Clean(filepath.Join("..", "..", ".."))
	scenariosRoot := filepath.Join(repositoryRoot, "tests", "azure", "azure_data_factory")

	for _, scenario := range terraformScenarios {
		scenario := scenario
		t.Run(scenario.name, func(t *testing.T) {
			scenarioDir := filepath.Join(scenariosRoot, scenario.directory)
			options := &terraform.Options{
				TerraformDir: scenarioDir,
				NoColor:      true,
				Reconfigure:  true,
			}

			terraform.InitAndApply(t, options)
			defer terraform.Destroy(t, options)

			require.Regexp(t, dataFactoryNamePattern, terraform.Output(t, options, "data_factory_name"))
			require.Regexp(t, dataFactoryIDPattern, terraform.Output(t, options, "data_factory_id"))
			require.Regexp(t, identityTenantIDPattern, terraform.Output(t, options, "data_factory_identity_tenant_id"))

			outputs := terraform.OutputAll(t, options)
			if len(scenario.expectedAlertNames) == 0 {
				require.NotContains(t, outputs, "data_factory_alerts")
				return
			}

			alerts, ok := outputs["data_factory_alerts"].(map[string]interface{})
			require.True(t, ok, "data_factory_alerts should be a map")
			require.Len(t, alerts, len(scenario.expectedAlertNames))
			for _, metric := range scenario.expectedAlertNames {
				require.Contains(t, alerts, metric)
				alertID, ok := alerts[metric].(string)
				require.True(t, ok, "alert %q should contain a string ID", metric)
				require.Regexp(t, metricAlertIDPattern, alertID)
			}
		})
	}
}

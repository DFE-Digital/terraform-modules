package azure_data_factory_test

import (
	"os"
	"path/filepath"
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestTerraformScenarios(t *testing.T) {
	repositoryRoot := filepath.Clean(filepath.Join("..", "..", ".."))
	scenariosRoot := filepath.Join(repositoryRoot, "tests", "azure", "azure_data_factory")

	entries, err := os.ReadDir(scenariosRoot)
	require.NoError(t, err)

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		scenarioDir := filepath.Join(scenariosRoot, entry.Name())
		mainFile := filepath.Join(scenarioDir, "main.tf")

		if _, err := os.Stat(mainFile); os.IsNotExist(err) {
			continue
		}

		t.Run(entry.Name(), func(t *testing.T) {
			t.Parallel()

			options := &terraform.Options{
				TerraformDir: scenarioDir,
				NoColor:      true,
			}

			terraform.InitAndApply(t, options)
			defer terraform.Destroy(t, options)

			require.Regexp(t, regexp.MustCompile(`^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$`), terraform.Output(t, options, "data_factory_name"))
			require.Regexp(t, regexp.MustCompile(`^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/Microsoft\.DataFactory/factories/[^/]+$`), terraform.Output(t, options, "data_factory_id"))
			require.Regexp(t, regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$`), terraform.Output(t, options, "data_factory_identity_tenant_id"))

			alerts := terraform.OutputMap(t, options, "data_factory_alerts")
			require.Len(t, alerts, 3)
			alertIDPattern := regexp.MustCompile(`^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/Microsoft\.Insights/metricAlerts/[^/]+$`)
			for _, metric := range []string{"FactorySizeInGbUnits", "PipelineFailedRuns", "ResourceCount"} {
				require.Contains(t, alerts, metric)
				require.Regexp(t, alertIDPattern, alerts[metric])
			}
		})
	}
}

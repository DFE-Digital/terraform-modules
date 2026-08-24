package azure_data_factory_test

import (
    "os"
    "path/filepath"
    "testing"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

func TestTerraformScenarios(t *testing.T) {
    repositoryRoot := filepath.Clean(filepath.Join("..", "..", "..", ".."))
    scenariosRoot := filepath.Join(repositoryRoot, "tests", "aks", "azure_data_factory")

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

            terraform.InitAndValidate(t, options)
        })
    }
}

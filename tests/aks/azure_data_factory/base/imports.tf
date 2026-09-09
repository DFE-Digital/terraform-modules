import  {
    id = "/subscriptions/5c83eb53-a94f-4778-b258-1f33efe49655/resourceGroups/s189d01-eprdat-ts-rg/providers/Microsoft.DataFactory/factories/s189d01-eprdat-development-adf"
    to = module.data_factory.azurerm_data_factory.main
}

import {
    id = "/subscriptions/5c83eb53-a94f-4778-b258-1f33efe49655/resourceGroups/s189d01-eprdat-ts-rg/providers/Microsoft.Storage/storageAccounts/s189d01eprdatdevelopment"
    to = module.data_factory.azurerm_storage_account.standard[0]
}
import {
    id = "/subscriptions/5c83eb53-a94f-4778-b258-1f33efe49655/resourceGroups/s189d01-eprdat-ts-rg/providers/Microsoft.KeyVault/vaults/s189d01-kv-eprdat-01"
    to = azurerm_key_vault.main
}


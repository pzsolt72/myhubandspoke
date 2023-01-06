az vm stop --no-wait --resource-group rg-northeurope-hub --name vm-northeurope-northtest
az vm stop --no-wait --resource-group rg-northeurope-spoke-01 --name vm-northeurope-spoke-01-1
az vm stop --no-wait --resource-group rg-northeurope-spoke-02 --name vm-northeurope-spoke-02-1
az vm stop --no-wait --resource-group rg-westeurope-hub --name vm-westeurope-test
az vm stop --no-wait --resource-group rg-westeurope-spoke-01 --name vm-westeurope-spoke-01-1
az vm stop --no-wait --resource-group rg-onprem --name vm-uksouth-onprem-1-1

az vm start --no-wait --resource-group rg-northeurope-hub --name vm-northeurope-northtest
az vm start --no-wait --resource-group rg-northeurope-spoke-01 --name vm-northeurope-spoke-01-1
az vm start --no-wait --resource-group rg-northeurope-spoke-02 --name vm-northeurope-spoke-02-1
az vm start --no-wait --resource-group rg-westeurope-hub --name vm-westeurope-test
az vm start --no-wait --resource-group rg-westeurope-spoke-01 --name vm-westeurope-spoke-01-1
az vm start --no-wait --resource-group rg-onprem --name vm-uksouth-onprem-1-1
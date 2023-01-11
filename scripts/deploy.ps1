az login 
az account set --subscription a8f77654-9254-4d5f-9c61-712b81de23c6

az vm image list --offer UbuntuServer --location eastus --all --output table

az group list --query "[].name" -o tsv

az deployment sub create --name 'myhubandspoke-deploy-all' --location westeurope --template-file .\templates\myHubAndSpoke.bicep

az deployment sub what-if --name 'myhubandspoke-deploy-all' --location westeurope --template-file .\templates\myHubAndSpoke.bicep

az deployment group create --name 'myhubandspoke-test' --resource-group 'rg-northeurope-hub' --template-file .\templates\dummy\test.bicep

 
az group delete --name rg-northeurope-hub --yes
az group delete --name rg-northeurope-spoke-01 --yes
az group delete --name rg-northeurope-spoke-02 --yes
az group delete --name rg-onprem --yes
az group delete --name rg-westeurope-hub --yes
az group delete --name rg-westeurope-spoke-01 --yes


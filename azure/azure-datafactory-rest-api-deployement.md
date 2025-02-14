[**_azure-datafactory-rest-api-deployement_**](https://learn.microsoft.com/en-us/rest/api/datafactory/datasets)

```yml
steps:
  - task: AzureCLI@2
    displayName: "Azure CLI login cred get from ado service connection"
    inputs:
      azureSubscription: "Development" # Azure Service Connection name based on project configuration
      scriptType: bash
      scriptLocation: inlineScript
      inlineScript: |
        servicePrincipalId=$(xxd -p -c 256 <<<$servicePrincipalId)
        servicePrincipalKey=$(xxd -p -c 256 <<<$servicePrincipalKey)
        tenantId=$(xxd -p -c 256 <<<$tenantId)
        appId=$(echo "${servicePrincipalId}" | xxd -r -p)
        appSecret=$(echo "${servicePrincipalKey}" | xxd -r -p)
        tId=$(echo "${tenantId}" | xxd -r -p)
        echo "##vso[task.setvariable variable=TENANT_ID]${tId}"
        echo "##vso[task.setvariable variable=APP_SECRET]${appSecret}"
        echo "##vso[task.setvariable variable=APP_ID]${appId}"
      addSpnToEnvironment: true
  - script: |
      [[ ! -z "$(APP_ID)" ]]     && echo "$(APP_ID) variable is valid"     || exit 1
      [[ ! -z "$(APP_SECRET)" ]] && echo "$(APP_SECRET) variable is valid" || exit 1
      [[ ! -z "$(TENANT_ID)" ]]  && echo "$(TENANT_ID) variable is valid"  || exit 1
    displayName: variable validation
  - bash: |
      token=$(curl -s -o /dev/null -X POST -d 'grant_type=client_credentials&client_id=${APP_ID}&client_secret=${APP_SECRET}&resource=https%3A%2F%2Fmanagement.azure.com%2F' https://login.microsoftonline.com/${TENANT_ID}/oauth2/token | jq '.access_token')
      echo "##vso[task.setvariable variable=ACCESS_TOKEN]$token"
    displayName: "create the bearer token"
  - bash: |
      for directory in $(ls -d */); do
          checkFileCountStatus=$(ls ${directory%%/} | wc -l)
          if [ "$checkFileCountStatus" != 0 ]; then
              for JsonFile in $(ls ${directory%%/} | grep .json); do
                  removeExtensionFromFile=$(echo "${JsonFile}" | cut -f1 -d'.')
                  if [ "${directory%%/}" == "dataflows" ]; then
                      absolutePath="${directory%%/}/${JsonFile}"
                      echo "##vso[task.setprogress value=$absolutePath;]Dataflows deployment going on!!!"
                      # status=$(curl -s -o /dev/null -X PUT -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" --data "@${absolutePath}" "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP}/providers/Microsoft.DataFactory/datafactories/${AZURE_DATA_FACOTRY_NAME}/dataflows/${removeExtensionFromFile}?api-version=2018-06-01")
                  fi
                  if [ "${directory%%/}" == "datasets" ]; then
                      echo "##[debug]Debug datasets enabled"
                      absolutePath="${directory%%/}/${JsonFile}"
                      echo "##vso[task.setprogress value=$absolutePath;]Datasets deployment going on!!!"
                      # status=$(curl -s -o /dev/null -X PUT -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" --data "@${absolutePath}" "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP}/providers/Microsoft.DataFactory/datafactories/${AZURE_DATA_FACOTRY_NAME}/datasets/${removeExtensionFromFile}?api-version=2018-06-01")
                  fi
                  if [ "${directory%%/}" == "triggers" ]; then
                      echo "##[debug]Debug triggers enabled"
                      absolutePath="${directory%%/}/${JsonFile}"
                      echo "##vso[task.setprogress value=$absolutePath;]Triggers deployment going on!!!"
                      # status=$(curl -s -o /dev/null -X PUT -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" --data "@${absolutePath}" "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP}/providers/Microsoft.DataFactory/datafactories/${AZURE_DATA_FACOTRY_NAME}/triggers/${removeExtensionFromFile}?api-version=2018-06-01")
                  fi
                  if [ "${directory%%/}" == "pipelines" ]; then
                      absolutePath="${directory%%/}/${JsonFile}"
                      echo "##vso[task.setprogress value=$absolutePath;]Pipelines deployment going on!!!"
                      # status=$(curl -s -o /dev/null -X PUT -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" --data "@${absolutePath}" "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP}/providers/Microsoft.DataFactory/datafactories/${AZURE_DATA_FACOTRY_NAME}/pipelines/${removeExtensionFromFile}?api-version=2018-06-01")
                  fi
                  if [ "${directory%%/}" == "linkedservices" ]; then
                      absolutePath="${directory%%/}/${JsonFile}"
                      echo "##vso[task.setprogress value=$absolutePath;]Linkedservices deployment going on!!!"
                      # status=$(curl -s -o /dev/null -X PUT -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" --data "@${absolutePath}" "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP}/providers/Microsoft.DataFactory/datafactories/${AZURE_DATA_FACOTRY_NAME}/linkedservices/${removeExtensionFromFile}?api-version=2018-06-01")
                  fi
              done
          else
              echo "${directory%%/} <= files are does not exist"
          fi
      done
    displayName: "adf deployment configuration"
    env:
      SUBSCRIPTION_ID: $(SUBSCRIPTION_ID)
      RESOURCE_GROUP: $(RESOURCE_GROUP)
      AZURE_DATA_FACOTRY_NAME: $(AZURE_DATA_FACOTRY_NAME)
      AZURE_SUBSCRIPTION_SERVICE_CONNECTION: $(AZURE_SUBSCRIPTION_SERVICE_CONNECTION)
```


[azure devOps logging](https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands?view=azure-devops&tabs=bash)

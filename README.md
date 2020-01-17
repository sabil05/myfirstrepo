# Design pattern for heartbeat-based VM rebuild with same OS boot volume

## Solution overview

ARM template is used to deploy new or use existing Log Analytics workspace, deploy a Linux VM within a new or existing Virtual Network, diagnostics storage account and connect VM to workspace, then create an Action Group and Alert Rule, as well as Automation Account and runbook (pulled from git repository). Alert Rule is created in Disabled state to ensure it is not triggered right after VM creation.
Then Automation Account manually populated with RunAsAccount and Action Group with webhook (not supported directly in ARM template so not automated) to be able to initiate a created Automation Runbook when heartbeats are lost for VM.
Once runbook triggered and rebuilds the VM Alert Rule will be disabled so that no further false positives happen (so it must be manually re-enabled in ~10 minutes).

Improvements advised:
- Add Azure Service Alerts to design and check its region-wide alerts first (for Compute-related e.g. Storage or Network or Compute services) before deleting VM and rebuilding it, because Azure in particular region might have service issues so there is no point to rebuild VM;
- Use single Alert Rule for many VMs as each rule cost ~1.5$ per month, or switch to different heartbeat mechanism (e.g. monitoring tool);
- •	Runbook use current VM config to rebuild VM, if VM is lost/incorrectly modified rebuilding VM will fail so it is advised to store VM config somewhere else (e.g. CMDB/git etc) and rebuild from that config.

## Preparations
Following prerequisites must be met:
- Automation Account prerequisites (https://docs.microsoft.com/en-us/azure/automation/manage-runas-account):
  - Azure subscription available with Contributor and User Access Administrator roles
  - Azure AD user must have Application Administrator role in Azure AD
- Browser (Chrome/Firefox, recent version)


## Step 1 – deploy ARM template

1. Open https://github.com/zhjuve/designpatterns/tree/master/000-vmrebuild
2. Click “Deploy to Azure”
3. Populate/change parameters as needed (at least Resource Group and password for VM):


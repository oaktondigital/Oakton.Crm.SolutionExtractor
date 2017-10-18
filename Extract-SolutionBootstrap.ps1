#
# Extractor bootstrap
#
#

.\Extract-CrmSolution.ps1 `
 -iscrmonline 1 `
 -interactivelogin 0 `
 -serverurl "https://yourcrm.crm6.dynamics.com" `
 -username "someone@ascesf2.onmicrosoft.com" `
 -password "*****************" `
 -solutionName "ASCESFSprint6" `
 -targetFolder "c:\temp\sol" `
 -region "Oceania" `
 -solutiontype 0 `
 -organisationname "Oakton-Sandbox"


#0 == Unmanaged, 1 == Managed, 2 == Both
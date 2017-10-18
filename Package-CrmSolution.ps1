param
(
    [parameter(Mandatory=$true)]
	[bool]$iscrmonline,
    [parameter(Mandatory=$true)]
	[Int16]$solutiontype, 
    [parameter(Mandatory=$true)]
	[bool]$interactivelogin,
    [parameter(Mandatory=$false)]
	[String]$serverurl,
    [parameter(Mandatory=$false)]
	[String]$username,
    [parameter(Mandatory=$false)]
	[String]$password,
    [parameter(Mandatory=$false)]
	[String]$solutionname,
    [parameter(Mandatory=$true)]
	[String]$targetfolder,
    [parameter(Mandatory=$true)]
	[String]$organisationname,
    [parameter(Mandatory=$false)]
	[String]$region

)

#initialise module
function initialize() {
    #Initialise the CRM module
	if (!(Get-Module "Microsoft.Xrm.Data.Powershell")) 	{
		Write-Verbose "Initialize Microsoft.Xrm.Data.Powershell"	
		Set-ExecutionPolicy –ExecutionPolicy RemoteSigned –Scope CurrentUser
		Import-Module Microsoft.Xrm.Data.PowerShell
	}
}

#Login to CRM
function login() {
	Write-Verbose("Logging in to CRM")

	$securePassword = ""
	$creds = ""

    #Interactive login - with UI
	if ($interactivelogin)	{
		if ($iscrmonline) {
            #Log in to CRM Online using the wizard.
			Write-Verbose "CRM Online login"
			Connect-CrmOnlineDiscovery -InteractiveMode
		}
		else
		{
            #Untested - Should prompt for username and password then login
			Write-Verbose "CRM On-Premise login"
			Connect-CrmOnPremDiscovery -Credential (Get-Credential) -ServerUrl $server
		}
	}
	else {
		Write-Verbose "Beginning non-interactive login"
		$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
		$creds = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

		if ($iscrmonline) {
            #Log in to CRM Online without any user input.
			Write-Verbose "CRM Online login"
            Connect-CrmOnlineDiscovery -Credential $creds -Region $region -Organisation $organisationname -ErrorAction Stop
 		}
		else
		{
            #Log in to CRM On-premise without any user input.
			Write-Verbose "CRM On-Premise login"
			Connect-CrmOnPremDiscovery -Credential $creds -ServerUrl $serverurl -OrganizationName $organisationname -ErrorAction Stop
		}
	}
}

function upload() {
    [int64]$maxWaitTimeInSeconds = 3000
	if (($solutiontype -eq 0) -or ($solutiontype -eq 2)) {
        #Unmanaged solution pack
		Write-Verbose "Unmanaged"
        $zipfile = $targetFolder+"\"+$exportZipFileName
        .\Executable\SolutionPackager.exe /a:Pack /packagetype:unmanaged /f:"$targetfolder" /z:"$zipfile" /ad:no
        Import-CrmSolution -conn $conn -SolutionFilePath "$zipfile" -PublishChanges $true -MaxWaitTimeInSeconds $maxWaitTimeInSeconds -ErrorAction Stop 
        Remove-Item  $zipfile  -Force
	}
	
	if (($solutiontype -eq 1) -or ($solutiontype -eq 2)) {
        #Managed solution pack
		Write-Verbose "Managed"
        $zipfile = $targetFolder+"\"+$exportZipFileNameManaged		
        .\Executable\SolutionPackager.exe /a:Pack /packagetype:managed /f:"$targetfolder" /z:"$zipfile" /ad:no

        Import-CrmSolution -conn $conn -SolutionFilePath "$zipfile" -PublishChanges $true -MaxWaitTimeInSeconds $maxWaitTimeInSeconds -ErrorAction Stop 
        Remove-Item  $zipfile  -Force
	}
}


$exportZipFileName = $solutionname + "_import.zip"
$exportZipFileNameManaged = $solutionname + "_managed_import.zip"

initialize
login
upload


#
# Extract_CrmSolution.ps1
#
#0 == Unmanaged, 1 == Managed, 2 == Both

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



$exportZipFileName = $solutionname + "_export.zip"
$exportZipFileNameManaged = $solutionname + "_export_Managed.zip"


function download() {
	Remove-Item $exportZipFileName -ErrorAction SilentlyContinue
	Remove-Item $exportZipFileNameManaged -ErrorAction SilentlyContinue
	Remove-Item -Recurse $targetfolder  -Force

	if (($solutiontype -eq 0) -or ($solutiontype -eq 2)) {
		Write-Verbose "Unmanaged"
		Export-CrmSolution -SolutionName $solutionName -SolutionZipFileName "$exportZipFileName"
		.\Executable\SolutionPackager.exe /a:extract /packagetype:unmanaged /f:"$targetfolder" /z:"$exportZipFileName" /ad:no /clobber
    
        Remove-Item  $exportZipFileName  -Force

	}
	
	if (($solutiontype -eq 1) -or ($solutiontype -eq 2)) {
		Write-Verbose "Managed"
		Export-CrmSolution -SolutionName $solutionName -Managed -SolutionZipFileName "$exportZipFileNameManaged"
		.\Executable\SolutionPackager.exe /a:extract /packagetype:managed /f:"$targetfolder" /z:"$exportZipFileName" /ad:no /clobber
        Remove-Item  $exportZipFileNameManaged  -Force
	}

}


function login() {
	Write-Verbose("Logging in to CRM")

	$securePassword = ""
	$creds = ""

	if ($interactivelogin)	{
		if ($iscrmonline) {
			Write-Verbose "CRM Online login"
			Connect-CrmOnlineDiscovery -InteractiveMode
		}
		else
		{
			Write-Verbose "CRM On-Premise login"
			Connect-CrmOnPremDiscovery -Credential (Get-Credential) -ServerUrl $server
		}
	}
	else {
		Write-Verbose "Beginning non-interactive login"
		$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
		$creds = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

		if ($iscrmonline) {
			Write-Verbose "CRM Online login"

           #  $global:conn = Get-CrmConnection -Credential $creds -OnLineType Office365 -OrganizationName $organisationname -ErrorAction Stop
            Connect-CrmOnlineDiscovery -Credential $creds -Region "Oceania" -Organisation $organisationname -ErrorAction Stop
 		}
		else
		{
			Write-Verbose "CRM On-Premise login"
			Connect-CrmOnPremDiscovery -Credential $creds -ServerUrl $serverurl -OrganizationName $organisationname -ErrorAction Stop
		}
	}
}

#Initialize the PowerShell module.
function initialize() {
	if (!(Get-Module "Microsoft.Xrm.Data.Powershell")) 	{
		Write-Verbose "Initialize Microsoft.Xrm.Data.Powershell"	
		Set-ExecutionPolicy –ExecutionPolicy RemoteSigned –Scope CurrentUser
		Import-Module Microsoft.Xrm.Data.PowerShell
	}
}




initialize
login
download
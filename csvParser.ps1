# Copyright (c) Microsoft Corporation. All rights reserved.  
# 
# THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK
# OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. 

# Synopsis: This script is designed to create recipients in Exchange Labs based on a CSV file containing data.
#
#
# Usage example:
#
#    Populate credentials to variable:
#    $cred = Get-Credential
#    -or-
#    $Username = "admin@mydomain.com"
#    $Password = ConvertTo-SecureString 'MyPassword' -AsPlainText -Force
#    $Livecred = New-Object System.Management.Automation.PSCredential $Username, $Password
#
#    -RemoteURL (Optional) is dependent on the Datacenter for Exchange Labs
#
#    -LogDirectory (Optional) is the directory where log files should be created.  Defaults to temp directory.
#    -LogVerbose turns on debug logging. Specify this switch parameter if requested by Microsoft Support.
#    -ValidateAction (Optional) is $true/$false for turning action validation on or off.
#       Action validation has an overhead of a few seconds per object.
#       If you are certain the action (Add/Update/Delete) does not need validation, you can turn it off.
#       The default value is $true for validation.
#    -StartRow (Optional) is the numeric row of the CSV file to start importing
#    -EndRow (Optional) is the numeric row of the CSV file to stop importing
#
#    .\CSV_Parser.PS1 -UsersFile C:\DataSource\test.csv -LiveCredential $Livecred -LogDirectory C:\Logging\ -ValidateAction $true
#
# Last Modified by eliask Sept 18th, 2009
#

Param(
	[string] $UsersFile = $(throw "Missing parameter: The -UsersFile parameter is required."),
	[string] $RemoteURL = "https://ps.outlook.com/powershell",
	[System.Management.automation.PSCredential] $LiveCredential = $(throw "Missing parameter: The -LiveCredential parameter is required."),
	[string] $LogDirectory = $null,
	[switch] $LogVerbose,
	[bool] $ValidateAction = $true,
	[int]$StartRow = 1,
	[int]$EndRow = 1000000
)

############################################################ Variable Declarations ################################################################

# Suppress warnings during script execution
# SilentlyContinue - continues running with no output
# Continue         - Print error and continue (default action)
# Inquire          - Ask users whether they want to continue, halt, or suspend
# Stop             - Halt execution of the command or script
$WarningPreference = "SilentlyContinue"

# Opens log file
$this_date = Get-Date
$format_date = $this_date.ToString("d") -replace "/", ""
$file_date = $format_date + "_" + $this_date.TimeOfDay.Hours + $this_date.TimeOfDay.Minutes + $this_date.TimeOfDay.Seconds

# Log is saved on the directory defined here
$file_name = "CSV_Parser_$($file_date).txt"
if ([String]::IsNullorEmpty($LogDirectory))
{
	$LogDirectory = "$Env:temp"
}
$file_name = $LogDirectory.TrimEnd('\') + "\$($file_name)"

# Global runspace variables
$Script:RS = $null
$Script:RSOpened = $false

# Max number of broken runspaces/retries
[int] $Script:MaxRSRetry = 30
[int] $Script:RSCounter = $null
[int] $Script:RSConnectionIssues = 0

[int] $Script:CurrentRow = 0
[bool] $Script:HasChanges = $false
[bool] $Script:HasRecipientChanges = $false
[bool] $Script:hasMailChanges = $false
[bool] $Script:RetryPass = $false
$Script:Names = New-Object System.Collections.Specialized.StringCollection
[System.Collections.Hashtable] $Script:AddedMbxes = New-Object System.Collections.Hashtable


#update warning message
$script:updateWarningMsg

#Script version
$scriptVersion="14.0.4.2"

#Exchange version
$script:isR3 = $false
$minimumR4ScriptVersion = new-object system.version "14.0.4.0"

############################################################ Variable Declarations End ############################################################

############################################################ Function Declarations ################################################################

# Adds to log file
function log
{
	Param($header,$Message)
	$log_date = Get-Date
	echo "[$($log_date)]: [$($header)]: $($Message)" >> $file_name
}


# Reconcile new value with current value and add to log file
function addProperty
{
	Param([System.Collections.ArrayList]$Props,[System.Collections.Hashtable]$OldValues, $PropLog, $NewValue)
	
	$PropName = $PropLog.Trim()
	
	$CompareValue1 = $null
	$CompareValue2 = $null
	
	# OldValues would be populated if $ValidateAction = $true and the object exists
	$OldValue = $null
	if ($OldValues.Contains($PropName))
	{
		$OldValue = $OldValues[$PropName]
	}
	if ($OldValue -ne $null)
	{
		if ($OldValue.GetType().ToString() -eq "System.Collections.ArrayList")
		{
			if ($OldValue.Count -eq 0)
			{
				$OldValue = $null
			}
			else
			{
				# We cannot compare two ArrayLists directly
				# Convert the ArrayList into a comparible string of all values
				$CompareValue1 = ""
				$sorted = $OldValue.ToArray()
				[Array]::Sort($sorted)
				foreach ($val in $sorted)
				{
					$CompareValue1 = $CompareValue1 + $val
				}
			}
		}
		else
		{
			if ([String]::IsNullorEmpty($OldValue.ToString()))
			{
				$OldValue = $null
			}
			else
			{
				$CompareValue1 = $OldValue
			}
		}
	}
	
	if ($NewValue -ne $null)
	{
		if ($NewValue.GetType().ToString() -eq "System.Collections.ArrayList")
		{
			if ($NewValue.Count -eq 0)
			{
				$NewValue = $null
			}
			else
			{
				# We cannot compare two ArrayLists directly
				# Convert the ArrayList into a comparible string of all values
				$CompareValue2 = ""
				$sorted = $NewValue.ToArray()
				[Array]::Sort($sorted)
				foreach ($val in $sorted)
				{
					$CompareValue2 = $CompareValue2 + $val
				}
			}   
		}
		else
		{
			if ([String]::IsNullorEmpty($NewValue.ToString()))
			{
				$NewValue = $null
			}
			else
			{
				$CompareValue2 = $NewValue
			}
		}
	}
	
	# Compare the two values to determine if there are changes
	$modified = " "
	if ($CompareValue1 -ne $CompareValue2)
	{
		$modified = "*"
		$Script:HasChanges = $true
		
		# Email Addresses & Custom Attributes require a separate cmdlet call
		# We do not want to make that call unless neccessary
		if (($PropName.StartsWith("EmailAddresses")) -or ($PropName.StartsWith("CustomAttribute")))
		{
			$Script:hasMailChanges = $true
		}
		else
		{
			$Script:HasRecipientChanges = $true
		}
	}
	
	if ($NewValue -eq $null)
	{
		# Preserve the current value if provided
		$NewValue = $OldValue
	}
	else
	{
		# Log the change
		$ChangeValue = ""
		if (($CompareValue1 -ne $CompareValue2) -and ($CompareValue1 -ne $null))
		{
			$ChangeValue = "   ($($OldValue))"
		}        
		logField "$($modified)$($PropLog)" "$($NewValue)$($ChangeValue)"
	}
	
	$Index = $Props.Add($NewValue)
}

function logField
{
	Param($PropName,$NewValue)    
	echo "     $($PropName) = $($NewValue)" >> $file_name
}

function logExit
{
	Param($header,$exitMessage)
	log $header $exitMessage
	echo $header $exitMessage
	if ($Script:RSOpened -eq $true)
	{
		clearRS
	}
	break
}

function error_logExit
{
	Param($header,$exitMessage,$moreInfoUrl)
	$moreInfo = "More information available at $moreInfoUrl"
	echo "Error = $($exitMessage)"
	echo $moreInfo
	log $header "$exitMessage $moreInfo"
	if ($Script:RSOpened -eq $true)
	{
		clearRS
	}
	showUpdateMessage
	throw
}

############################################################
## Runspace Functions ######################################
############################################################

function openRS
{
	$error.Clear()
	# Creating new runspace. AllowRedirection parameter automatically directs to the correct Datacenter depending on the tenant name.
	$Script:RS = New-PSSession -ConfigurationName microsoft.exchange -ConnectionUri $RemoteURL -Credential $LiveCredential -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue
	if ([String]::IsNullorEmpty($error[0]))
	{
		log "Success" "Runspace Creation was successful = $($RemoteURL)"
		if ($Script:RSOpened -eq $false)
		{
			$Script:RSOpened = $true
		}
	}
	else
	{
		retryRS
	}
}

function clearRS
{
	$error.Clear()
	
	# Removes runspace 
	$Script:RS | Remove-PSSession -ErrorAction SilentlyContinue
	if ([String]::IsNullorEmpty($error[0]))
	{
		log "Terminating" "Successfully cleared Runspace = $($RemoteURL)"
	}
	else
	{
		if ($LogVerbose -eq $true)
		{
			$errcheck = $null
			$errcheck = $error[0].exception | select *
			log "Debug" $errcheck
		}
		log "Terminating" "Clearing Runspace was unsuccessful. Error = $($error[0])"
	}
}

function retryConnectionIssues
{
	## I/O error condition, typically either a network connectivity issue or an incorrect URI
	$Script:RSConnectionIssues = $Script:RSConnectionIssues + 1
	if ($Script:RSConnectionIssues -gt 10)
	{
		log "Error" "Connectivity issues are continuing to prevent a runspace from being created. Error code: 995. Please check the the URL ($($RemoteURL)). Waiting for 5 mins before retry"
		sleep -seconds "300"
	}
	else 
	{
		log "Error" "Connectivity issues are preventing a runspace from being created/persisted. Error code: 995. Please check the the URL ($($RemoteURL)). Retrying in 30 secs"
		sleep -seconds "30"
	}
}

function retryErrorGeneric
{
	param($msg,$waitTime)
	log "Error" $msg
	sleep -seconds $waitTime
}

function retryRS
{
	$errcheck = $null
	$errcheck = $error[0].exception | select *

	## debuging code for runspace open
	if ($LogVerbose -eq $true)
	{
		log "Debug" $errcheck
	}
	
	$Script:RSCounter = $Script:RSCounter + 1
	if ($Script:RSCounter -gt $Script:MaxRSRetry)
	{
		## too many retries
		error_logExit "Terminating" $connectionErrors["default"][0] $connectionErrors["default"][1]
	}
	
	$errorcode = $errcheck.errorcode
	if ($errorcode -eq $null -or !$connectionErrors.ContainsKey($errorcode))
	{
		$errorcode = "default"
	}

	if ($Script:RSOpened -eq $false -and $errorcode -ne "default")
	{
		error_logExit "Terminating" $connectionErrors[$errorcode][0] $connectionErrors[$errorcode][1]
	}

	## if specific function defined run it, otherwise get message 
	## and wait time from error definition map
	if ($connectionErrors[$errorcode][2].GetType().Name -ieq "ScriptBlock")
	{
		& $connectionErrors[$errorcode][2]
	}
	else
	{
		retryErrorGeneric ($connectionErrors[$errorcode][2] -f $error[0]) $connectionErrors[$errorcode][3]
	}
	echo "Retrying..."
	openRS
}

function CheckRSState
{
	echo "checking runspace status"
	$rsstate = $null
	$rsstate = (Get-PSSession -InstanceId $Script:RS.InstanceId).state
	# echo "Runspace: "$rsstate
	log "Checking" "Runspace: $($rsstate)"
	if ($rsstate -ne "Opened")
	{
		log "Error" "Runspace $($rsstate)" 
		clearRS
		openRS 
	}
}

function checkVersionStatus
{
	log "Pre-Validation" "Provisioning with csv_parser.ps1 version ($scriptVersion)."
	echo "Provisioning with csv_parser.ps1 version ($scriptVersion)."

	$toolInformation = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $scriptVersion {param ($version) get-toolInformation -Identity csvparser -version $version}
	if ($toolInformation -ne $null)
	{
		
		# if minimum supported version is still in R3 script range we're running against R3
		$minimumSupportedVersion = $toolInformation.MinimumSupportedVersion
		$script:isR3 = ($minimumSupportedVersion -ne $null -and $minimumSupportedVersion -lt $minimumR4ScriptVersion)

		$updateUrl = $toolInformation.UpdateInformationUrl
		if ($toolInformation.VersionStatus -ieq "NewerVersionAvailable")
		{
			$script:updateWarningMsg = "There is a newer version of this script available for download. More information available at $updateUrl"
			showUpdateMessage
		}
		elseif ($toolInformation.VersionStatus -ieq "VersionNoLongerSupported")
		{
			error_logExit "Terminating" "This script version ($scriptVersion) is no longer supported. Please update to the latest version." $updateUrl 
		}
	}
	
}

function showUpdateMessage
{
	if ($script:updateWarningMsg -ne $null)
	{
		write-host $script:updateWarningMsg
		log "Update" $script:updateWarningMsg
	}
}

############################################################
## processFile #############################################
############################################################

# The function will go through all the rows in $UserFile, taking the appropriate action
# It will mark the row as Done, unles there has to be a retry, in which case will mark
# the row as Retry.
# Any row already marked as Done will be skipped.
# Any row already marked as Retry will be marked as Done after one retry.
function processFile
{
	Param($UserFile)

	$Script:CurrentRow = 0
	
	# Filters records and calls appropriate cmdlets
	foreach ($user in $UserFile)
	{
		$continue = $false
		$Script:CurrentRow = $Script:CurrentRow + 1        
		if (($Script:CurrentRow -ge $StartRow) -and ($Script:CurrentRow -le $EndRow) -and (![String]::IsNullorEmpty($user)))
		{
			if ([String]::IsNullorEmpty($user.Name))
			{
				log "Error" "Can not import user at row $($Script:CurrentRow). Please check your CSV file format"
				echo "Can not import user at row $($Script:CurrentRow). Please check your CSV file format."
			}
			else
			{
				# Validate the Action
				$continue = $true
				switch ($user.Action)
				{
					$null {$user.Action = "Add"}
					"Add" {}
					"Create" {$user.Action = "Add"}
					"Update" {}
					"Modify" {$user.Action = "Update"}
					"Delete" {}
					"Remove" {$user.Action = "Delete"}
					"PasswordReset" {}
					"Set" {}
					"RetryAdd" {}
					"RetryUpdate" {}
					"RetryDelete" {}
					"Done" {$continue = $false}
					default
					{
						$continue = $false
						log "Error" "Import action of '$($this_action)' for $($this_name) at row $($Script:CurrentRow) is unknown"
						echo "Import action of '$($this_action)' for $($this_name) at row $($Script:CurrentRow) is unknown."
					}
				}
			}
		}
		if ($continue -eq $true)
		{
			# Validate the boolean property for Force Change Password
			if (![String]::IsNullorEmpty($user.ForceChangePassword))
			{                
				if (($user.ForceChangePassword -eq "0") -or ($user.ForceChangePassword -eq "1"))
				{}
				else
				{
					$boolVal = $true
					if ([System.Boolean]::TryParse($user.ForceChangePassword, [ref] $boolVal))
					{
						if ($boolVal -eq $false)
						{
							$user.ForceChangePassword = "0"
						}
						else
						{
							$user.ForceChangePassword = "1"
						}
					}
					else
					{
						$continue = $false
						log "Error" "ForceChangePassword value of '$($user.ForceChangePassword)' for $($this_name) at row $($Script:CurrentRow) is unknown"
						echo "ForceChangePassword value of '$($user.ForceChangePassword)' for $($this_name) at row $($Script:CurrentRow) is unknown."
					}
				}
			}
		}
		if ($continue -eq $true)
		{
			$this_date = Get-Date
				
			$props = New-Object System.Collections.ArrayList
			$mailProps = New-Object System.Collections.ArrayList
			$oldValues = New-Object System.Collections.Hashtable
			$Script:HasChanges = $false
			$Script:HasRecipientChanges = $false
			$Script:hasMailChanges = $false            

			# Capture the properties needed to do cmdlet's other than Update/Set/Retry
			$this_name = $user.Name
			$this_action = $user.Action
			$this_type = $user.Type
			$this_email = $user.EmailAddress
			if (![String]::IsNullorEmpty($user.Password))
			{
				$this_pwd = ConvertTo-SecureString $user.Password -AsPlainText -Force
			}
			else
			{
				$this_pwd = $user.Password
			}
						
			$this_firstName = $user.FirstName
			$this_lastName = $user.LastName
			$this_displayName = $user.DisplayName
			if ([String]::IsNullorEmpty($this_displayName))
			{
				$this_displayName = $this_email
			}
			$this_initials = $user.Initials

			
			# Capture the boolean property for Force Change Password
			# Note:  The value is validated above
			$this_resetpwd = $true
			if (![String]::IsNullorEmpty($user.ForceChangePassword))
			{
				if ($user.ForceChangePassword -eq "0")
				{
					$this_resetpwd = $false
				}
			}
			
			# Build the list of Proxy Email Addresses
			$this_emailAddresses = New-Object System.Collections.ArrayList
			if (![String]::IsNullorEmpty($this_email))
			{
				$index = $this_emailAddresses.Add("SMTP:$($this_email)")
				
				if (![String]::IsNullorEmpty($user.EmailAddress2))
				{
					$index = $this_emailAddresses.Add("smtp:$($user.EmailAddress2)")
				}
				if (![String]::IsNullorEmpty($user.EmailAddress3))
				{
					$index = $this_emailAddresses.Add("smtp:$($user.EmailAddress3)")
				}
				if (![String]::IsNullorEmpty($user.EmailAddress4))
				{
					$index = $this_emailAddresses.Add("smtp:$($user.EmailAddress4)")
				}
				if (![String]::IsNullorEmpty($user.EmailAddress5))
				{
					$index = $this_emailAddresses.Add("smtp:$($user.EmailAddress5)")
				}
			}
	
			# By default, set this row as done
			$user.Action = "Done"

			# Add the static values that cannot change
			$index = $oldValues.Add("Name", $this_name)
			$index = $oldValues.Add("EmailAddress", $this_email)

			# If the user was added in this session then use the properties of the new mailbox
			# as oldvalues so it won't go into the pahse2, set-values section, to reset the same properties.  
			if ($Script:AddedMbxes[$this_name])
			{
				$index = $oldValues.Add("FirstName", $this_firstName)
				$index = $oldValues.Add("LastName", $this_lastName)
				$index = $oldValues.Add("DisplayName", $this_displayName)
				$index = $oldValues.Add("Initials", $this_Initials)
				$emailAddresses = New-Object System.Collections.ArrayList
		            	if (![String]::IsNullorEmpty($this_email))
            			{
               				$index = $emailAddresses.Add("SMTP:$($this_email)")
				}
		            	$index = $oldValues.Add("EmailAddresses", $emailAddresses)
			}
			
					
			log "Importing" "Starting import for = $($this_name) at row $($Script:CurrentRow)"
			echo "Starting import for = $($this_name) at row $($Script:CurrentRow)"

			# Keep a list of all objects updated in this session to keep proper count
			if (!$Script:Names.Contains($this_name))
			{
				$index = $Script:Names.Add($this_name)
			}

			$error.Clear()

			# Validate the Action
			if (($ValidateAction -ne $false) -and ($this_action -ne "Set"))
			{
				if ($this_type -eq "Mailbox")
				{
					$this_mail = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $this_name {param ($identity) get-mailbox -Identity $identity}
					if ([String]::IsNullorEmpty($error[0]))
					{
						$this_addrbook = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $this_name {param ($identity) get-user -Identity $identity}
					}
				}
				elseif ($this_type -eq "MailUser")
				{
					$this_mail = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $this_name {param ($identity) get-mailuser -Identity $identity}
					if ([String]::IsNullorEmpty($error[0]))
					{
						$this_addrbook = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $this_name {param ($identity) get-user -Identity $identity}
					}
				}
				elseif ($this_type -eq "MailContact")
				{
					$this_mail = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $this_name {param ($identity) get-mailcontact -Identity $identity}
					if ([String]::IsNullorEmpty($error[0]))
					{
						$this_addrbook = Invoke-Command -Session $Script:RS -ErrorAction SilentlyContinue -arg $this_name {param ($identity) get-contact -Identity $identity}
					}
				}
				if ([String]::IsNullorEmpty($error[0]))
				{
					log "Importing" "$($this_type) Exists."
					if (($this_action -eq "Add") -or ($this_action -eq "RetryAdd"))
					{
						$this_action = "Update"
					}
					
					if (($this_pwd -ne $null) -and (![String]::IsNullorEmpty($this_pwd)))
					{
						# Password Reset has been initialized
						$Script:HasChanges = $true
					}
					
					# if the user was added in Phase 1, then here in phase 3 some of the old values are already set.
					if (!$Script:AddedMbxes[$this_name])
					{
						$index = $oldValues.Add("DisplayName", $this_addrbook.DisplayName)
						$index = $oldValues.Add("FirstName", $this_addrbook.FirstName)
						$index = $oldValues.Add("LastName", $this_addrbook.LastName)
						$index = $oldValues.Add("Initials", $this_addrbook.Initials)
						$index = $oldValues.Add("EmailAddresses", $this_mail.EmailAddresses)
					}
					$index = $oldValues.Add("Company", $this_addrbook.Company)
					$index = $oldValues.Add("StreetAddress", $this_addrbook.StreetAddress)
					$index = $oldValues.Add("City", $this_addrbook.City)
					$index = $oldValues.Add("StateorProvince", $this_addrbook.StateorProvince)
					$index = $oldValues.Add("PostalCode", $this_addrbook.PostalCode)
					$index = $oldValues.Add("CountryorRegion", $this_addrbook.CountryorRegion)
					$index = $oldValues.Add("Department", $this_addrbook.Department)
					$index = $oldValues.Add("Phone", $this_addrbook.Phone)
					$index = $oldValues.Add("Fax", $this_addrbook.Fax)
					$index = $oldValues.Add("HomePhone", $this_addrbook.HomePhone)
					$index = $oldValues.Add("MobilePhone", $this_addrbook.MobilePhone)
					$index = $oldValues.Add("Notes", $this_addrbook.Notes)
					$index = $oldValues.Add("Office", $this_addrbook.Office)
					$index = $oldValues.Add("Title", $this_addrbook.Title)
					$index = $oldValues.Add("WebPage", $this_addrbook.WebPage)
					$index = $oldValues.Add("CustomAttribute1", $this_mail.CustomAttribute1)
					$index = $oldValues.Add("CustomAttribute2", $this_mail.CustomAttribute2)
					$index = $oldValues.Add("CustomAttribute3", $this_mail.CustomAttribute3)
					$index = $oldValues.Add("CustomAttribute4", $this_mail.CustomAttribute4)
					$index = $oldValues.Add("CustomAttribute5", $this_mail.CustomAttribute5)
					$index = $oldValues.Add("CustomAttribute6", $this_mail.CustomAttribute6)
					$index = $oldValues.Add("CustomAttribute7", $this_mail.CustomAttribute7)
					$index = $oldValues.Add("CustomAttribute8", $this_mail.CustomAttribute8)
					$index = $oldValues.Add("CustomAttribute9", $this_mail.CustomAttribute9)
					$index = $oldValues.Add("CustomAttribute10", $this_mail.CustomAttribute10)
					$index = $oldValues.Add("CustomAttribute11", $this_mail.CustomAttribute11)
					$index = $oldValues.Add("CustomAttribute12", $this_mail.CustomAttribute12)
					$index = $oldValues.Add("CustomAttribute13", $this_mail.CustomAttribute13)
					$index = $oldValues.Add("CustomAttribute14", $this_mail.CustomAttribute14)
					$index = $oldValues.Add("CustomAttribute15", $this_mail.CustomAttribute15)
				}
				else
				{
					log "Importing" "$($this_type) Does Not Exist"
					if ($this_action -eq "Update")
					{
						$this_action = "Add"
					}
					elseif ($this_action -eq "Delete")
					{
						$this_action = "Done"
						log "Error" "$($this_type) deletion was unsuccessful. Error= $($error[0])"
						echo "$($this_type) deletion was unsuccessful. See Log for details."
					}
					elseif ($this_action -eq "RetryDelete")
					{
						$this_action = "Done"
					}
					elseif ($this_action -eq "PasswordReset")
					{
						$this_action = "Done"
						log "Error" "Password Reset was unsuccessful. Error= $($error[0])"
						echo "Password Reset was unsuccessful. See Log for details."
					}
				}
			}
			else
			{
				$Script:HasChanges = $true
			}

			$error.Clear()            
			
			if ($this_action -eq "Done")
			{
				#Don't do anything since validation failed
			}
			elseif (($this_action -eq "Add") -or ($this_action -eq "RetryAdd"))
			{
				$Script:HasChanges = $true
				logField                      "*Name             " $this_name
				logField                      "*EmailAddress     " $this_email
				logField                      "*Passw.           " $this_pwd
				logField                      "*ForcePassChange  " $this_resetpwd
				logField                      "*DisplayName      " $this_displayName
				logField                      "*FirstName        " $this_firstName
				logField                      "*LastName         " $this_lastName
				logField                      "*Initials         " $this_initials
			}
			elseif ($this_action -eq "PasswordReset")
			{
				$Script:HasChanges = $true
				logField                      " Name             " $this_name
				logField                      " EmailAddress     " $this_email
				logField                      "*Passw.           " $this_pwd
			}
			elseif (($this_action -eq "Delete") -or ($this_action -eq "RetryDelete"))
			{
				$Script:HasChanges = $true
				logField                      " Name             " $this_name
				logField                      " EmailAddress     " $this_email
			}
			else
			{
				# The Properties are added with ordinal positions
				# During the execution of each cmdlet, the order is represented with 
				# Parameters starting with $1,$2,$3,etc  (Name,DisplayName,FirstName,etc)
				addProperty $props $oldValues "Name             " $this_name            #1
				logField                      " EmailAddress     " $this_email
				if (($this_pwd -ne $null) -and (![String]::IsNullorEmpty($this_pwd)))
				{
					logField                  "*Passw.           " $this_pwd
				}
				addProperty $props $oldValues "DisplayName      " $user.DisplayName     #2
				addProperty $props $oldValues "FirstName        " $user.FirstName       #3
				addProperty $props $oldValues "LastName         " $user.LastName        #4
				addProperty $props $oldValues "Initials         " $user.Initials        #5
				addProperty $props $oldValues "Company          " $user.Company         #6
				addProperty $props $oldValues "StreetAddress    " $user.StreetAddress   #7
				addProperty $props $oldValues "City             " $user.City            #8
				addProperty $props $oldValues "StateorProvince  " $user.StateorProvince #9
				addProperty $props $oldValues "PostalCode       " $user.PostalCode      #10
				addProperty $props $oldValues "CountryorRegion  " $user.CountryorRegion #11
				addProperty $props $oldValues "Department       " $user.Department      #12
				addProperty $props $oldValues "Phone            " $user.Phone           #13
				addProperty $props $oldValues "Fax              " $user.Fax             #14
				addProperty $props $oldValues "HomePhone        " $user.HomePhone       #15
				addProperty $props $oldValues "MobilePhone      " $user.MobilePhone     #16
				addProperty $props $oldValues "Notes            " $user.Notes           #17
				addProperty $props $oldValues "Office           " $user.Office          #18
				addProperty $props $oldValues "Title            " $user.Title           #19
				addProperty $props $oldValues "WebPage          " $user.WebPage         #20
				
				$index = $mailProps.Add($this_name)                                           #1
				addProperty $mailProps $oldValues "EmailAddresses   " $this_emailAddresses    #2
				addProperty $mailProps $oldValues "CustomAttribute1 " $user.CustomAttribute1  #3
				addProperty $mailProps $oldValues "CustomAttribute2 " $user.CustomAttribute2  #4
				addProperty $mailProps $oldValues "CustomAttribute3 " $user.CustomAttribute3  #5
				addProperty $mailProps $oldValues "CustomAttribute4 " $user.CustomAttribute4  #6
				addProperty $mailProps $oldValues "CustomAttribute5 " $user.CustomAttribute5  #7
				addProperty $mailProps $oldValues "CustomAttribute6 " $user.CustomAttribute6  #8
				addProperty $mailProps $oldValues "CustomAttribute7 " $user.CustomAttribute7  #9
				addProperty $mailProps $oldValues "CustomAttribute8 " $user.CustomAttribute8  #10
				addProperty $mailProps $oldValues "CustomAttribute9 " $user.CustomAttribute9  #11
				addProperty $mailProps $oldValues "CustomAttribute10" $user.CustomAttribute10 #12
				addProperty $mailProps $oldValues "CustomAttribute11" $user.CustomAttribute11 #13
				addProperty $mailProps $oldValues "CustomAttribute12" $user.CustomAttribute12 #14
				addProperty $mailProps $oldValues "CustomAttribute13" $user.CustomAttribute13 #15
				addProperty $mailProps $oldValues "CustomAttribute14" $user.CustomAttribute14 #16
				addProperty $mailProps $oldValues "CustomAttribute15" $user.CustomAttribute15 #17
			}
			
			if ($Script:HasChanges -ne $true)
			{
				$this_date2 = Get-Date
			
				if ($this_action -eq "Done")
				{
					log "Importing" "Skipping action for $($this_name)"
					echo "Skipping action for $($this_name) ($($this_date2.Subtract($this_date).TotalSeconds))"
				}
				else
				{
					$this_action = "Done"
					log "Importing" "No Changes are required for $($this_name), skipping update"
					echo "No Changes are required for $($this_name), skipping update ($($this_date2.Subtract($this_date).TotalSeconds))"
				}
			}

			$error.Clear()

			if ($this_action -ne "Done")
			{
				$this_date2 = Get-Date

				log "Importing" "Performing $($this_action) for = $($this_name)"
				echo "Performing $($this_action) for = $($this_name) ($($this_date2.Subtract($this_date).TotalSeconds))"

				# Check action type
				if (($this_action -eq "Add") -or ($this_action -eq "RetryAdd"))
				{
									
					if ($this_type -eq "Mailbox")
					{
						# create mailbox - assigning result to variable to avoid listing the new object
						
						if (![String]::IsNullorEmpty($user.MailboxPlan))
						{
							$this_mailboxPlan = $user.MailboxPlan    
							%{Invoke-Command -Session $Script:RS {param ($name,$pwd,$email,$resetpwd,$mailboxPlan,$firstName,$lastName,$displayName,$initials) new-mailbox -Name $name -Password $pwd -WindowsLiveID $email -ResetPasswordOnNextLogon $resetpwd -MailboxPlan $mailboxPlan -FirstName $firstName -LastName $lastName -DisplayName $displayName -Initials $initials}-arg $this_name,$this_pwd,$this_email,$this_resetpwd,$this_mailboxPlan,$this_firstName,$this_lastName,$this_displayName,$this_initials} > $results
						}
						else
						{
    							%{Invoke-Command -Session $Script:RS {param ($name,$pwd,$email,$resetpwd,$firstName,$lastName,$displayName,$initials) new-mailbox -Name $name -Password $pwd -WindowsLiveID $email -ResetPasswordOnNextLogon $resetpwd -FirstName $firstName -LastName $lastName -DisplayName $displayName -Initials $initials}-arg $this_name,$this_pwd,$this_email,$this_resetpwd,$this_firstName,$this_lastName,$this_displayName,$this_initials} > $results
						}

						if ([String]::IsNullorEmpty($error[0]))
						{
							# if everything went fine, we update the data in the next iteration
							$user.Action = "Set"
							# Mark this mailbox as a new add, that way, 
							# Phase2 set-mailbox won't try to re-set the attributes. 
							if (!$Script:AddedMbxes[$this_name])
							{
								$Script:AddedMbxes.Add($this_name,$true)
							}
						}
						else
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryAdd")
							{                                
								log "Importing" "Mailbox creation was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryAdd"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mailbox creation was unsuccessful. Error= $($error[0])"
								echo "Mailbox creation was unsuccessful. See Log for details."
							}
						}
					}
					elseif ($this_type -eq "MailUser")
					{
						# create mail user - assigning result to variable to avoid listing the new object
						%{Invoke-Command -Session $Script:RS {param ($name,$email,$firstName,$lastName,$displayName) new-mailuser -Name $name -ExternalEmailAddress $email -FirstName $firstName -LastName $lastName -DisplayName $displayName}-arg $this_name,$this_email,$this_firstName,$this_lastName,$this_displayName} > $results
						if ([String]::IsNullorEmpty($error[0]))
						{
							# if everything went fine, we update the data in the next iteration
							$user.Action = "Set"
						}
						else
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryAdd")
							{                                
								log "Importing" "Mail User creation was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryAdd"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mail User creation was unsuccessful. Error= $($error[0])"
								echo "Mail User creation was unsuccessful. See Log for details."
							}
						}
					}
					elseif ($this_type -eq "MailContact")
					{
						# create mail contact - assigning result to variable to avoid listing the new object
						%{Invoke-Command -Session $Script:RS {param ($name,$email,$firstName,$lastName,$displayName) new-mailcontact -Name $name -ExternalEmailAddress $email -FirstName $firstName -LastName $lastName -DisplayName $displayName}-arg $this_name,$this_email,$this_firstName,$this_lastName,$this_displayName} > $results
						if ([String]::IsNullorEmpty($error[0]))
						{
							# if everything went fine, we update the data in the next iteration
							$user.Action = "Set"
						}
						else
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryAdd")
							{                                
								log "Importing" "Mail Contact creation was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryAdd"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mail Contact creation was unsuccessful. Error= $($error[0])"
								echo "Mail Contact creation was unsuccessful. See Log for details."
							}
						}
					}
					else
					{
						log "Error" "Can not create user: $this_name. Recipient Type: $($this_type)"
						echo "Can not create user: $this_name. Recipient Type: $($this_type)."
					}
				}
				
				
				elseif ($this_action -eq "PasswordReset")
				{
					echo "Performing password reset for $this_name.  You may ignore the following warning."
					$error.Clear()
					%{Invoke-Command -Session $Script:RS -ErrorAction $WarningPreference {param ($name,$pwd) set-mailbox -Identity $name -Password $pwd} -arg $this_name,$this_pwd} > $results

					if (![String]::IsNullorEmpty($error[0]))
					{
						log "Error" "Password Reset was unsuccessful. Error= $($error[0])"
						echo "Password Reset was unsuccessful. See Log for details."
					}
				}
								
				
				elseif (($this_action -eq "Update") -or ($this_action -eq "Set") -or ($this_action -eq "RetryUpdate"))
				{
					if ($this_type -eq "Mailbox")
					{                                                
						# update mailbox with Mailbox Data
						if (([String]::IsNullorEmpty($error[0])) -and ($Script:hasMailChanges -eq $true))
						{
							$error.Clear()
							Invoke-Command -Session $Script:RS -arg $mailProps -ErrorAction $WarningPreference {param ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17) set-mailbox -Identity $1 -EmailAddresses $2 -CustomAttribute1 $3 -CustomAttribute2 $4 -CustomAttribute3 $5 -CustomAttribute4 $6 -CustomAttribute5 $7 -CustomAttribute6 $8 -CustomAttribute7 $9 -CustomAttribute8 $10 -CustomAttribute9 $11 -CustomAttribute10 $12 -CustomAttribute11 $13 -CustomAttribute12 $14 -CustomAttribute13 $15 -CustomAttribute14 $16 -CustomAttribute15 $17}
						}
						
						# update mailbox with User Data
						if (([String]::IsNullorEmpty($error[0])) -and ($Script:HasRecipientChanges -eq $true))
						{
							$error.Clear()
							Invoke-Command -Session $Script:RS -arg $props -ErrorAction $WarningPreference {param ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20) set-user -Identity $1 -DisplayName $2 -FirstName $3 -LastName $4 -Initials $5 -Company $6 -StreetAddress $7 -City $8 -StateorProvince $9 -PostalCode $10 -CountryorRegion $11 -Department $12 -Phone $13 -Fax $14 -HomePhone $15 -MobilePhone $16 -Notes $17 -Office $18 -Title $19 -WebPage $20}
						}
						
						# Perform a password reset if the Password is specified
						if (([String]::IsNullorEmpty($error[0])) -and ($this_action -eq "Update") -and (![String]::IsNullorEmpty($this_pwd)))
						{
							log "Importing" "Performing password reset for $this_name."
							echo "Performing password reset for $this_name.  You may ignore the following warning."
							$error.Clear()
							Invoke-Command -Session $Script:RS -ErrorAction $WarningPreference {param ($name,$pwd,$resetpwd) set-mailbox -Identity $name -Password $pwd -ResetPasswordOnNextLogon $resetpwd} -arg $this_name,$this_pwd,$this_resetpwd
						}
					
						if (![String]::IsNullorEmpty($error[0]))
						{
							# If this is the first time we try this operation, let's retry it later                            
							if ($this_action -ne "RetryUpdate")
							{
								log "Importing" "Mailbox update was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryUpdate"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mailbox update was unsuccessful. Error= $($error[0])"
								echo "Mailbox update was unsuccessful. See Log for details."
							}
						}
					}
					elseif ($this_type -eq "MailUser")
					{                        
						# update mail user with MailUser Data
						if (([String]::IsNullorEmpty($error[0])) -and ($Script:hasMailChanges -eq $true))
						{
							$error.Clear()
							Invoke-Command -Session $Script:RS -arg $mailProps -ErrorAction $WarningPreference {param ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17) set-mailuser -Identity $1 -EmailAddresses $2 -CustomAttribute1 $3 -CustomAttribute2 $4 -CustomAttribute3 $5 -CustomAttribute4 $6 -CustomAttribute5 $7 -CustomAttribute6 $8 -CustomAttribute7 $9 -CustomAttribute8 $10 -CustomAttribute9 $11 -CustomAttribute10 $12 -CustomAttribute11 $13 -CustomAttribute12 $14 -CustomAttribute13 $15 -CustomAttribute14 $16 -CustomAttribute15 $17}
						}
						
						# update mail user with User Data
						if (([String]::IsNullorEmpty($error[0])) -and ($Script:HasRecipientChanges -eq $true))
						{
							$error.Clear()
							Invoke-Command -Session $Script:RS -arg $props -ErrorAction $WarningPreference {param ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20) set-user -Identity $1 -DisplayName $2 -FirstName $3 -LastName $4 -Initials $5 -Company $6 -StreetAddress $7 -City $8 -StateorProvince $9 -PostalCode $10 -CountryorRegion $11 -Department $12 -Phone $13 -Fax $14 -HomePhone $15 -MobilePhone $16 -Notes $17 -Office $18 -Title $19 -WebPage $20}
						}
					
						if (![String]::IsNullorEmpty($error[0]))
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryUpdate")
							{
								log "Importing" "Mail User update was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryUpdate"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mail User update was unsuccessful. Error= $($error[0])"
								echo "Mail User update was unsuccessful. See Log for details."
							}
						}
					}
					elseif ($this_type -eq "MailContact")
					{                        
						# update mail contact with MailContact Data
						if (([String]::IsNullorEmpty($error[0])) -and ($Script:hasMailChanges -eq $true))
						{
							$error.Clear()
							Invoke-Command -Session $Script:RS -arg $mailProps -ErrorAction $WarningPreference {param ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17) set-mailcontact -Identity $1 -EmailAddresses $2 -CustomAttribute1 $3 -CustomAttribute2 $4 -CustomAttribute3 $5 -CustomAttribute4 $6 -CustomAttribute5 $7 -CustomAttribute6 $8 -CustomAttribute7 $9 -CustomAttribute8 $10 -CustomAttribute9 $11 -CustomAttribute10 $12 -CustomAttribute11 $13 -CustomAttribute12 $14 -CustomAttribute13 $15 -CustomAttribute14 $16 -CustomAttribute15 $17}
						}
						
						# update mail contact with Contact Data
						if (([String]::IsNullorEmpty($error[0])) -and ($Script:HasRecipientChanges -eq $true))
						{
							$error.Clear()
							Invoke-Command -Session $Script:RS -arg $props -ErrorAction $WarningPreference {param ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20) set-contact -Identity $1 -DisplayName $2 -FirstName $3 -LastName $4 -Initials $5 -Company $6 -StreetAddress $7 -City $8 -StateorProvince $9 -PostalCode $10 -CountryorRegion $11 -Department $12 -Phone $13 -Fax $14 -HomePhone $15 -MobilePhone $16 -Notes $17 -Office $18 -Title $19 -WebPage $20}
						}
						
						if (![String]::IsNullorEmpty($error[0]))
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryUpdate")
							{
								log "Importing" "Mail Contact update was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryUpdate"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mail Contact update was unsuccessful. Error= $($error[0])"
								echo "Mail Contact update was unsuccessful. See Log for details."
							}
						}
					}
					else
					{
						log "Error" "Can not update user: $($this_name). Recipient Type: $($this_type)"
						echo "Can not update user: $($this_name). Recipient Type: $($this_type)"
					}
				}
				
				
				elseif (($this_action -eq "Delete") -or ($this_action -eq "RetryDelete"))
				{
					if ($this_type -eq "Mailbox")
					{
						# delete mailbox
						if ($script:isR3)
						{
							if ($user.KeepWindowsLiveID -ieq "Y")
							{
								# If the user decides to keep the Live ID, we call remove-mailbox without any switch
								%{Invoke-Command -Session $Script:RS {param ($this_name) remove-mailbox -Identity $this_name -Confirm:$false}-arg $this_name} 
							}
							else
							{
								# If the user decides to delete the Live ID along with mailbox, we call Remove-Mailbox with DisableWindowsLiveId
								%{Invoke-Command -Session $Script:RS {param ($this_name) remove-mailbox -Identity $this_name -DisableWindowsLiveID -Confirm:$false}-arg $this_name} 
							}
						}
						else
						{	                    
							if ($user.KeepWindowsLiveID -ieq "Y")
							{
								# If the user decides to keep the Live ID, we call remove-mailbox with -KeepWindowsLiveID
								%{Invoke-Command -Session $Script:RS {param ($this_name) remove-mailbox -Identity $this_name -KeepWindowsLiveID -Confirm:$false}-arg $this_name} 
							}
							else
							{
								# If the user decides to delete the Live ID along with mailbox, we call Remove-Mailbox without any switch
								%{Invoke-Command -Session $Script:RS {param ($this_name) remove-mailbox -Identity $this_name -Confirm:$false}-arg $this_name} 
							}
						}
						if (![String]::IsNullorEmpty($error[0]))
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryDelete")
							{
								log "Importing" "Mailbox deletion was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryDelete"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mailbox deletion was unsuccessful. Error= $($error[0])"
								echo "Mailbox deletion was unsuccessful. See Log for details."
							}
						}
					}
					elseif ($this_type -eq "MailUser")
					{
						# delete mail user
						%{Invoke-Command -Session $Script:RS {param ($this_name,$this_Phone) remove-mailuser -Identity $this_name -Confirm:$false}-arg $this_name}
						if (![String]::IsNullorEmpty($error[0]))
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryDelete")
							{
								log "Importing" "Mail User deletion was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryDelete"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mail User deletion was unsuccessful. Error= $($error[0])"
								echo "Mail User deletion was unsuccessful. See Log for details."
							}
						}
					}
					elseif ($this_type -eq "MailContact")
					{
						# delete mail contact
						%{Invoke-Command -Session $Script:RS {param ($this_name,$this_Phone) remove-mailcontact -Identity $this_name -Confirm:$false}-arg $this_name}
						if (![String]::IsNullorEmpty($error[0]))
						{
							# If this is the first time we try this operation, let's retry it later
							if ($this_action -ne "RetryDelete")
							{
								log "Importing" "Mail Contact deletion was unsuccessful and it will be retried later."
								CheckRSState
								$user.Action = "RetryDelete"
								$Script:RetryPass = $true
							}
							else
							{
								log "Error" "Mail Contact deletion was unsuccessful. Error= $($error[0])"
								echo "Mail Contact deletion was unsuccessful. See Log for details."
							}
						}
					}
					else
					{
						log "Error" "Cannot import user: $this_name. Recipient Type: $($this_type)"
						echo "Cannot import user: $this_name. Recipient Type: $($this_type)"
					}
				}

				$this_date2 = Get-Date
				echo "Finished $($this_action) for = $($this_name) ($($this_date2.Subtract($this_date).TotalSeconds))"
			}
		}
	}
}

############################################################ Function Declarations End ############################################################

############################################################ Main Script Block ####################################################################

#Error information
#error code = <terminating error message>,<troubleshooting url>,(<retry message>,<retry timout>|<custom retry script block>)
$connectionErrors = @{
	-2144108123 = "PowerShell quota exceeded. Wait 15 minutes and try again.",
				  "http://go.microsoft.com/fwlink/?LinkID=147836",
				  "PowerShell quota exceeded. Error code -2144108123. Waiting 16 mins for an inactive runspace to expire.",
				   960;
	995 =         "No network connection. Please check the the URL and try again ($($RemoteURL)).",
				  "http://go.microsoft.com/fwlink/?LinkID=147837",
				  $function:retryConnectionIssues;
	5 =           "Accessed Denied from remote service. Error code: 5. Please check credentials (Username:$($LiveCredential.username)) and URL ($($RemoteURL)).",
				  "http://go.microsoft.com/fwlink/?LinkID=147838",
				  "Remote PowerShell service reporting access denied. Error code: 5. Retrying in 30 secs.",
				  30;
	"default" =   "Too many broken runspaces.",
				  "http://go.microsoft.com/fwlink/?LinkID=147839",
				  "Runspace Creation was unsuccessful. Error = {0}.",
				  0;
}

log "Initializing" ""
log "Initializing" "Starting Import: $($this_date)"
log "Pre-Validation" "Users File = $($UsersFile)"
log "Pre-Validation" "Remote URL = $($RemoteURL)"
log "Pre-Validation" "Live Creds = $($LiveCredential)"
log "Pre-Validation" "Validate Action = $($ValidateAction)"
log "Pre-Validation" "Start Row = $($StartRow)"
log "Pre-Validation" "End Row = $($EndRow)"
log "Pre-Validation" "LogVerbose = $($LogVerbose)"

$start_date = Get-Date

if ($StartRow -ne 1)
{
	echo "Starting on row $($StartRow)"
}
if ($EndRow -ne 1000000)
{
	echo "Ending on row $($EndRow)"
}


# Tries to create Runspace
$error.Clear()

openRS

if (![String]::IsNullorEmpty($error[0]))
{
   logExit "Pre-validation" "Runspace creation was unsuccessful. Step: check creds and URL. Error= $($error[0])"
}
else
{
   log "Pre-Validation" "Successfully created Runspace for = $($RemoteURL)"
}

# check for updates
checkVersionStatus

# read recipients to be created
$error.Clear()
$UserFile = import-csv -Path $UsersFile -OutVariable string -ErrorAction $WarningPreference 
if (![String]::IsNullorEmpty($error[0]))
{
   logExit "Pre-validation" "CSV Import was unsuccessful. Step: Opening User list file. Error= $($error[0])"
}

log "Importing" "Starting CSV Import"
echo "Starting CSV Import"

# Process file the first time to execute all the create/delete operations
echo "Phase 1: Add/Update/Delete operations"
log "Importing" "Phase 1: Add/Update/Delete operations"
processFile $UserFile

# Process file a second time to execute all set/update operations
echo "Phase 2: Set operations"
log "Updating" "Phase 2: Set operations"
processFile $UserFile

# Finally, process file a third time to retry failures
if ($Script:RetryPass)
{
	# let's give the topology some time to replicate the objects before retrying
	echo "Waiting 30 seconds to allow replication"
	echo "Phase 3: Retry operations"
	log "Retry" "Phase 3: Retry operations"
	[System.Threading.Thread]::Sleep(30000)
	$WarningPreference = "Continue"
	processFile $UserFile
}

$end_date = Get-Date
$timeSpan = $end_date.Subtract($start_date)
$elapsed = [String]::Format("{0} Hours {1} Minutes  {2} Seconds", $timeSpan.Hours.ToString(), $timeSpan.Minutes.ToString(), $timeSpan.Seconds.ToString())
$ProcessCount = $Script:Names.Count

#remind about update if needed
showUpdateMessage

log "Terminating" "Processed $($ProcessCount) objects in $($elapsed)."
logExit "Terminating" "Finished CSV_Parser.PS1 Script. Please check $($file_name) for details."


############################################################ Main Script End ####################################################################


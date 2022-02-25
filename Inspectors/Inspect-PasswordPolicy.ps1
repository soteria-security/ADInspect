<#
.SYNOPSIS
    Gather information about the Active Directory Domain Password Policy
.DESCRIPTION
    This script checks Active Directory Active Directory Domain Password Policy
.COMPONENT
    PowerShell, Active Directory PowerShell Module
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Active Directory Domain Password Policy
#>

$path = @($out_path)
Function Inspect-PasswordPolicy { 

    $ADRoot = Get-ADRootDSE

    $PasswordPolicy = Get-ADObject $ADRoot.defaultNamingContext -Property minPwdAge, maxPwdAge, minPwdLength, pwdHistoryLength, pwdProperties 

    $data = $PasswordPolicy | Select-Object @{n="minPwdAge";e={"$($_.minPwdAge / -864000000000) days"}},@{n="maxPwdAge";e={"$($_.maxPwdAge / -864000000000) days"}},minPwdLength,pwdHistoryLength,`
        @{n="pwdProperties";e={Switch ($_.pwdProperties) {
            0 {"Passwords can be simple and the administrator account cannot be locked out"} 
            1 {"Passwords must be complex and the administrator account cannot be locked out"}
            8 {"Passwords can be simple, and the administrator account can be locked out"}
            9 {"Passwords must be complex, and the administrator account can be locked out"}
            Default {$_.pwdProperties}
            }
        }
    }

    $flag = $false

    If ($null -ne $data){
        $flag = $true
    }

    $data | Out-File "$($path)\Domain_Password_Policies.txt"

    Return "$flag - Please refer to Domain_Password_Policies.txt output file"
}

Return Inspect-PasswordPolicy

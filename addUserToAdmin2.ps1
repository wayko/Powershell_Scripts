$Password = ConvertTo-SecureString "H@rr1s@EvL543210" -AsPlainText -Force
New-LocalUser -Name "hcsadmin" -Password $Password -Description "HSC Admin"

Add-LocalGroupMember -Group "Administrators" -Member "hcsadmin"

Get-LocalUser -Name "hcsadmin"
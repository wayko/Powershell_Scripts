$RandomString = -join ((48..57) + (65..90) + (97..122) + (33..47)+(58..64)+(91..96)+(123..126) | Get-Random -Count 20 | ForEach-Object {[char]$_})

$RandomString
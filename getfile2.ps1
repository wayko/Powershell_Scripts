
$source3 = "https://1drv.ms/u/s!AojlY36Hi_BskAOIsn1Jbb3UxweN?e=XdkexQ" 
$downloadPath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders").PSObject.Properties["{374DE290-123F-4565-9164-39C4925E467B}"].Value 
$source5 = "https://public.bn.files.1drv.com/y4mwk_mMwgMCfo3LUv60UdAeGuPCgxsNmApf_LXgxAm7TlfpnquTpFeRe_JpwhyG1KVxqj4PKGB26EGUv_S79j77YaC-jlWcBkkkypk8_JgOIb3mAIX3w03Kj4LQBOwk2pUBCLO9_EbT5T-kjV22Is5oNkNMy827Ztvw9MC0fQh3QsZFMPpOHxC-kk-OLGlmSQA5bPip3JeuoqYbVav-9X2ShwF56AyUp3Lnl2kRVCr5CU?AVOverride=1"



$source4 = "https://public.bn.files.1drv.com/y4mq2H9tP92UjE0qz8VoMofsXtPjxUMybdrRXR5RScxqhCbdRrjzqi_hqyL24oI5NczlUy5tQzuXgmZVfHjMjyP-rEZLTTHgyP0oTZSFH_WHm76ue_2fseBEU9FJiUosdzHwSRwitCsU6CesiLAQUm70WFyJy_1bOjEXJNKGhvXsSXZGjRaxv4rjZZQA_xjGobxvO5rS6rfGOxoSt6pks-rVwgissafwIx1y5VAucq44E8?AVOverride=1"
$downloadfile = Invoke-WebRequest -Uri $source4 -UseBasicParsing
$downloadfile.Headers

$content = [System.Net.Mime.ContentDisposition]::new($downloadfile.Headers["Content-Disposition"])
$content




$fileName = $content.FileName

 $Directory = "c:\temp\test"
  if (!$fileName) {
        Write-Error $errorMessage -ErrorAction Stop
    }

    if (!(Test-Path -Path $Directory)) {
        New-Item -Path $Directory -ItemType Directory
    }
    
    $fullPath = Join-Path -Path $Directory -ChildPath $fileName

    Write-Verbose "Downloading to $fullPath"

$file = [System.IO.FileStream]::new($fullPath, [System.IO.FileMode]::Create)
    $file.Write($downloadFile.Content, 0, $downloadFile.RawContentLength)
    $file.Close()



 Start-Process -FilePath "C:\temp\test\SentinelCleaner_21.11_x64.exe" 
 Stop-Process -Name powershell_ise
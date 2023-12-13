$connectTestResult = Test-NetConnection -ComputerName 10.0.0.4 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.0.0.5`" /user:`"localhost\naikgroupteststorage1`" /pass:`"j98R26R+mK7YT76I8wXNyD27LF4GJF9BPAiSZ+o3xbPDabbZQ4vesRzw8jU/KkheThmP+V2Hj5i4+AStVbNUSA==`""
    # Mount the drive
    New-PSDrive -Name L -PSProvider FileSystem -Root "\\10.0.0.4\testxdrive" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
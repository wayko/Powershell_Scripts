Function Invoke-WakeOnLan { 
[OutputType()]
Param (
    [Parameter(ValueFromPipeline)]
    [String[]]$MacAddress
)


    Begin {

        # The following table contains aliases for commonly used MAC addresses; modify as required.

        $StaticLookupTable=@{
            Hyperion  = '00-1F-D0-98-CD-44'
            Nova      = '00-1D-92-3B-C2-C8'
            Desktop   = '00-15-58-9B-6A-1B'
            Laptop    = '00-17-08-42-D5-18'
            AD2       = '00-1F-D0-98-CD-5C'
            Server3   = '00-0E-2E-49-25-32'
            Media     = '1C-6F-65-D7-20-D7'
        }
  
        $UdpClient = New-Object System.Net.Sockets.UdpClient
    }



    Process {

        Foreach ($MacString in $MacAddress) {
        
            # Check to see if a known MAC alias has been specified; if so, substitute the corresponding address
            
            If ($StaticLookupTable.ContainsKey($MacString)) {
                Write-Verbose -Message "Found '$MacString' in lookup table"
                $MacString = $StaticLookupTable[$MacString]
            }

            # Validate the MAC address, 6 hex bytes separated by : or -

            If ($MacString -NotMatch '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$') {
                Write-Warning "Mac address '$MacString' is invalid; must be 6 hex bytes separated by : or -" 
                Continue      
            }

            # Split and convert the MAC address to an array of bytes

            $Mac = $MacString.Split('-:') | Foreach {[Byte]"0x$_"}

            # WOL Packet is a byte array with the first six bytes 0xFF, followed by 16 copies of the MAC address

            $Packet = [Byte[]](,0xFF * 6) + ($Mac * 16)
            # Write-Verbose "Broadcast packet: $([BitConverter]::ToString($Packet))" # Un-comment this line to display packet

            $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),4000)  # Send packets to the Broadcast address
            [Void]$UdpClient.Send($Packet, $Packet.Length)

            Write-Verbose "Wake-on-Lan Packet sent to $MacString"
        }
    }



    End {
        $UdpClient.Close()
        $UdpClient.Dispose()
    }
}

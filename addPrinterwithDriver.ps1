param (
    [string]$PrinterIP,
    [string]$PrinterHostname,
    [string]$DriverURL
)

# Function to install printer driver
function Install-PrinterDriver {
    param (
        [string]$DriverURL,
        [string]$DriverName
    )

    # Download the printer driver
    $tempDir = "$env:TEMP\PrinterDriver"
    $driverFilePath = "$tempDir\$DriverName"
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    Invoke-WebRequest -Uri $DriverURL -OutFile $driverFilePath

    # Install the printer driver
    Add-PrinterDriver -Name $DriverName -InfPath $driverFilePath
}

# Function to add printer
function Add-PrinterByIP {
    param (
        [string]$PrinterIP,
        [string]$DriverName,
        [string]$PortName,
        [string]$PrinterName
    )

    # Add the printer port
    Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP

    # Add the printer
    Add-Printer -ConnectionName "\\$PrinterIP\$PrinterName" -DriverName $DriverName -PortName $PortName -Shared -ShareName $PrinterName
}

# Main script
try {
    if ($PrinterIP -and $PrinterHostname) {
        throw "Please specify only one of PrinterIP or PrinterHostname."
    }

    if (-not ($PrinterIP -or $PrinterHostname)) {
        throw "Please specify either PrinterIP or PrinterHostname."
    }

    if (-not $DriverURL) {
        throw "Please specify the DriverURL parameter."
    }

    # Get printer details based on IP or hostname
    $printer = $null
    if ($PrinterIP) {
        $printer = Get-WmiObject -Class Win32_Printer -Filter "PortName LIKE '%$PrinterIP%'"
    } else {
        $printer = Get-WmiObject -Class Win32_Printer -Filter "Name LIKE '%$PrinterHostname%'"
    }

    if ($printer -eq $null) {
        throw "Printer not found."
    }

    # Install printer driver if needed
    $driverName = "Printer Driver Name"  # Replace with the actual driver name
    Install-PrinterDriver -DriverURL $DriverURL -DriverName $driverName

    # Add printer
    $portName = "IP_$($printer.PortName.Replace(".", "_"))"
    $printerName = $printer.Name
    Add-PrinterByIP -PrinterIP $printer.PortName -DriverName $driverName -PortName $portName -PrinterName $printerName

    Write-Host "Printer added successfully."
} catch {
    Write-Host "Error: $_"
}

﻿Get-Content $env:UserProfile”\AppData\Roaming\Microsoft\Teams\settings.json” | ConvertFrom-Json | Select Version, Ring, Environment
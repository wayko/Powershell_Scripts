

    Function Get-OutlookSentItems

    {

     Add-type -assembly “Microsoft.Office.Interop.Outlook” | out-null

     $olFolders = “Microsoft.Office.Interop.Outlook.olDefaultFolders” -as [type]

     $outlook = new-object -comobject outlook.application

     $namespace = $outlook.GetNameSpace(“MAPI”)

     $folder = $namespace.getDefaultFolder($olFolders::olFolderSentMail)
     $folder2 = $namespace.getDefaultFolder($olFolders::olFolderInbox)

     $folder.items |

     Select-Object -Property Subject, SentOn, Importance, To

    }

    $sentItems = Get-OutlookSentItems

    $sentItems.count
    

    $sentItems | where { $_.subject -match ‘test’ } |

         sort SentOn -Descending | select subject, senton -last 5
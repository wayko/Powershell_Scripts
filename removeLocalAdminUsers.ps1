$members = "RMM_Agent","DVR","jbear","jgr","joe","jxm","jzb","kcory","KME","lab","labgf","Linda","lscha","markm","Megan","Nathan Pritchard","netspec","newuser","omoreno","Owner","Pack1","pack3","Parts Room","PMZ","pressuser","spk-adp","tgt","TrainingPC","zerega","ZGuggenberger" 

foreach($member in $members)
{
    Remove-LocalGroupMember -Group "Administrators" -Member $members
}

Remove-LocalUser -Name $members
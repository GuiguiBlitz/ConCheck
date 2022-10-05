$curDate = Get-Date -Format "dddd-MM-dd-yyyy-HH-mm"
Start-Transcript -Path .\log\check_connections_$curDate.log
Write-Host "Source Host : " $(hostname) 
#Test TCP
Write-Host "$(Get-Date)+-+-+-+-+-+-+-+-Verrification des acces serveurs via tcp+-+-+-+-+-+-+-+-"
Import-Csv .\host.csv | ForEach-Object{
    $hostname = $_.Host
    $port = $_.Port
    try{
        $connection = New-Object System.Net.Sockets.TcpClient($hostname , $port ) -ErrorAction Stop
        if ($connection.Connected) {
            Write-Host "$(Get-Date) | Success | $hostname : $port " 
        }
        else{
            Write-Host "$(Get-Date) | Failed  | $hostname : $port " 
        }
    }
    catch{
         Write-Host "$(Get-Date) | Failed  | $hostname : $port " 
    }
}

#Test de chemins reseaux
Write-Host "$(Get-Date)+-+-+-+-+-+-+-+-Verrification des acces via chemins reseaux+-+-+-+-+-+-+-+-"
Import-Csv .\path.csv | ForEach-Object{
    $testPath = $_.Path
    $testUser = $_.User
    $testPwd = $_.Pwd
    try{
        New-SmbMapping -LocalPath L: -RemotePath $testPath -username $testUser -Password $testPwd -ErrorAction Stop | Out-Null
        $status = Get-SmbMapping  -LocalPath L:  | Select-Object -Property Status 
        if ($status.Status -eq 'OK') {
            Write-Host "$(Get-Date) | Success | $testPath : $testUser : ***** " 
            Remove-SmbMapping -LocalPath L: -Force
        }
        else{
            Write-Host "$(Get-Date) | Failed  | $testPath : $testUser : ***** " 
        }
    }
    catch{
         Write-Host "$(Get-Date) | Failed  |  $testPath : $testUser : ***** "  
    }
}
Stop-Transcript

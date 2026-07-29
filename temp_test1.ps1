$p = Start-Process -FilePath "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug\cpp-tests.exe" -WorkingDirectory "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug" -PassThru -WindowStyle Normal -RedirectStandardOutput "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug\cpp-tests-stdout.log" -RedirectStandardError "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug\cpp-tests-stderr.log"
Start-Sleep -Seconds 6
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect("127.0.0.1", 5678)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true
$reader = New-Object System.IO.StreamReader($stream)
Start-Sleep -Milliseconds 300
$buf = New-Object char[] 65536
$n = $reader.Read($buf, 0, 65536)
$tests = @("Configuration","FileUtils","UserDefault","Current Language","Fonts","Scheduler","ActionManager","Actions - Basic","Actions - Ease","Actions - Progress","Node: Node","Node: Scene","Node: Layer","Node: Sprite","Node: Menu")
$results = @()
foreach ($t in $tests) {
    $writer.WriteLine("autotest $t")
    Start-Sleep -Seconds 1
    $n = $reader.Read($buf, 0, 65536)
    $resp = [string]::new($buf, 0, $n)
    $results += "[$t]: $resp"
    Write-Host "[$t] OK"
    $writer.WriteLine("autotest main")
    Start-Sleep -Milliseconds 500
    $n = $reader.Read($buf, 0, 65536)
}
$results | Out-File "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug\test-batch1.log" -Encoding utf8
$stream.Close()
$client.Close()
Write-Host "Batch 1 completed"

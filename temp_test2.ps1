$client = New-Object System.Net.Sockets.TcpClient
$client.Connect("127.0.0.1", 5678)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true
$reader = New-Object System.IO.StreamReader($stream)
Start-Sleep -Milliseconds 300
$buf = New-Object char[] 65536
$n = $reader.Read($buf, 0, 65536)
$tests = @("Node: Label - New API","Node: Label - Old API","Node: Draw","Node: Parallax","Node: Clipping","Node: RenderTexture","Node: MotionStreak","Node: Particles","Node: TileMap","Node: Text Input","Node: Physics","Node: Spine","Transitions","Effects - Basic","Effects - Advanced")
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
$results | Out-File "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug\test-batch2.log" -Encoding utf8
$stream.Close()
$client.Close()
Write-Host "Batch 2 completed"

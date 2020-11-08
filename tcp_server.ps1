$server = New-Object System.Net.Sockets.TcpListener -ArgumentList 6996
$server.Start()


Write-Host "Listening on port 6996 for clients to accept..."
$client = $server.AcceptTcpClient()
$stream = $client.GetStream()

[byte[]]$bytes = New-Object byte[] 32
$stream.read($bytes,0,$bytes.Length)
$message = [System.Convert]::ToBase64String($bytes)
Write-Host $message

$server.stop()
$server.Server.Dispose()

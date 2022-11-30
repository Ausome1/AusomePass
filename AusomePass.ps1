cls;

Write-Host "`n      ▄████████████▄
      █            █ 
      █            █       /\           /\            
      █            █__/\__/  \__/\/\_/\/  \/\___/\                        
      █  ███       █══════════════════════════════\ 
      █            █¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/ 
      █            █¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
      █            █" -NoNewline;Write-Host -ForegroundColor Gray "  A U S O M E PASS     v1.0";
Write-Host "      ▀████████████▀`n";       

# Config
$salt = 'NF0K1YgAWQsE'
$hash_algorithm = 'SHA512'
$min_password_length_returned = 16
# Config

# Do Not Change Code Below This Line

function JumbleIt ([String] $text) {
    [string] $r = ''

    foreach ($c in $text.ToCharArray()) {
        [int] $n = $c

        if ( ( $n -ge  97  -and  $n -le 109 ) -or ( $n -ge 65 -and $n -le 77 ) ) { 
            $r += [char] ($n + 13) 
        }
        elseif ( ( $n -ge 110  -and  $n -le 122 ) -or ( $n -ge 78 -and $n -le 90 ) ) { 
            $r += [char] ($n - 13)
        }
        else {
            $r += $c
        }
    }

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($r)
    $JumbledText =[Convert]::ToBase64String($Bytes)
    return $JumbledText
}

function HashIt ([String] $InputString, $HashAlgo) {
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($InputString)
    $writer.Flush()
    $stringAsStream.Position = 0
    $hash = (Get-FileHash -Algorithm $HashAlgo -InputStream $stringAsStream | Select-Object Hash).Hash.ToCharArray()
    
    for ($i=0;$i -lt $min_length;$i++) {
        if ($i % 2 -eq 0) {
            $hash[$i].ToString().ToLower()
        }
    }
    
    return $hash
}

$website = read-host -prompt 'Enter Target (ex: Website, Server)'
$secured_master_password = read-host -prompt 'Enter Master Password' -AsSecureString

do {
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Title = "Select something you own. This is used for password entropy."
    }
    $null = $FileBrowser.ShowDialog()
} while ($FileBrowser.FileName -eq "")


$something_you_own = (Get-FileHash -Algorithm MD5 -Path $FileBrowser.FileName).Hash

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secured_master_password)
$master_password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

if ($website -match '^http') {
    $url = $website
} else {
    $url = 'https://' + $website
}

$domain = ([Uri]$url).Authority -replace '^www\.'
$hash = HashIt ($domain.Trim().ToLower() + $master_password.Trim() + $something_you_own + $salt) $hash_algorithm
$password = (JumbleIt ($hash -join "")).Substring(0, $min_password_length_returned -1)
$password.trim() | clip

$shell = New-Object -ComObject "WScript.Shell"
$button = $shell.Popup("Your password has been copied to your clipboard.", 0, "Copied", 0)

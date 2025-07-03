$wxlFiles = @(
    "1029", "1031", "1036", "1040", "1041", "1042", "1045", "1046", "1049", "1055", "2052", "3082"
)

foreach ($locale in $wxlFiles) {
    $filePath = "c:\Users\mmcgaw\repos\windowsdesktop\src\windowsdesktop\src\bundle\theme\$locale\bundle.wxl"
    Write-Host "Processing: $filePath"
    
    # Read content
    $content = Get-Content $filePath -Raw -Encoding UTF8
    
    # Update namespace
    $content = $content -replace 'xmlns="http://schemas\.microsoft\.com/wix/2006/localization"', 'xmlns="http://wixtoolset.org/schemas/v4/wxl"'
    
    # Process each String element line by line
    $lines = $content -split "`r?`n"
    $newLines = @()
    
    $i = 0
    while ($i -lt $lines.Length) {
        $line = $lines[$i]
        
        if ($line -match '^\s*<String Id="([^"]*)"([^>]*)>(.*)$') {
            $indent = ($line -replace '^(\s*).*', '$1')
            $id = $matches[1]
            $rest = $matches[3]
            
            # Single line string
            if ($rest -match '^(.*)</String>\s*$') {
                $value = $matches[1]
                $newLines += "$indent<String Id=`"$id`" Value=`"$value`"/>"
            }
            else {
                # Multi-line string
                $value = $rest
                $i++
                while ($i -lt $lines.Length -and $lines[$i] -notmatch '</String>') {
                    if ($value -ne "") { $value += "&#xD;&#xA;" }
                    $value += $lines[$i].Trim()
                    $i++
                }
                if ($i -lt $lines.Length -and $lines[$i] -match '^(.*)</String>') {
                    if ($matches[1].Trim() -ne "") {
                        if ($value -ne "") { $value += "&#xD;&#xA;" }
                        $value += $matches[1].Trim()
                    }
                }
                $newLines += "$indent<String Id=`"$id`" Value=`"$value`"/>"
            }
        }
        else {
            $newLines += $line
        }
        $i++
    }
    
    # Write back
    $newContent = $newLines -join "`r`n"
    [System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
    Write-Host "  Updated successfully!"
}

Write-Host "All files processed!"

#!usr/bin/env powershell
# https://github.com/YIsoda/IonBeamDataProcessTools

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]$Path,
    # 入力された数のchannel数ごとに和をとって1つのchannel（ビン）にします
    [Parameter()][ValidateRange(1, 1000)][int]$BinWidth = 1,
    [Parameter()][ValidateRange(1, 100000)][int]$RbsMaxCh = 10000,
    [Parameter()][ValidateRange(1, 100000)][int]$ErdMaxCh = 10000
)

Write-Output $path

# ファイルをCSV形式として読み込む
# "Select" operation in .NET, a.k.a. "map" in other language (https://en.wikipedia.org/wiki/Map_(higher-order_function))
$fileContent = Import-Csv $path -Header "ch", "CH1", "CH2", "CH3", "CH4" | Select-Object -Property ch, CH1, CH2

# 最初の列の値が"[Data]"である行のインデックスを求める
$dataStartIndex = [array]::IndexOf($fileContent.ch, "[Data]")
$rawData = $fileContent[($dataStartIndex + 2)..($fileContent.Length)]

if ($BinWidth -eq 1) {
    $processedData = $rawData
}
elseif ($BinWidth -gt 1) {
    $processedData = @()
    # [int[]]
    $rowsInChunk = @(0, 0)
    [int]$chunkCount = 0
    [int]$channelsCount = 0
    foreach ($channelRow in
        ($rawData | Select-Object -Property CH1, CH2)
    ) {
        $rowsInChunk[0] += $channelRow.CH1
        $rowsInChunk[1] += $channelRow.CH2
        $chunkCount += 1
        if ($chunkCount -eq $BinWidth) {
            $processedData += [PSCustomObject]@{
                ch  = $channelsCount
                CH1 = $rowsInChunk[0]
                CH2 = $rowsInChunk[1]
            }
            $chunkCount = 0
            $rowsInChunk = @(0, 0)
            $channelsCount += 1
        }
    }
}



$outDir = Join-Path (Get-Item $Path).DirectoryName "Dat"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir
}
$baseName = (Get-Item $path).BaseName
$rbsFileName = Join-Path $outDir "$($baseName)_rbs.dat"
$erdFileName = Join-Path $outDir "$($baseName)_erd.dat"
$processedCsvFileName = Join-Path $outDir "$($baseName)_.csv"

if ($RbsMaxCh -eq 0) {
    $RbsMaxCh = $processedData.Length
}
if ($ErdMaxCh -eq 0) {
    $ErdMaxCh = $processedData.Length
}
[int]$MaxCh = 0
if ($RbsMaxCh -gt $ErdMaxCh) {
    $MaxCh = $RbsMaxCh
}
else {
    $MaxCh = $ErdMaxCh
}


$processedData[0..$RbsMaxCh] | Select-Object -Property "ch", "CH1" | ConvertTo-Csv -QuoteFields False -Delimiter "`t" | Out-File -Force -FilePath $rbsFileName -Encoding utf8
$processedData[0..$ErdMaxCh] | Select-Object -Property "ch", "CH2" | ConvertTo-Csv -QuoteFields False -Delimiter "`t" | Out-File -Force -FilePath $erdFileName -Encoding utf8
$processedData[0..$MaxCh] | ConvertTo-Csv -QuoteFields False -Delimiter "," | Out-File -Force -FilePath $processedCsvFileName -Encoding utf8

Write-Output "--- RBS ---"
$processedData[0..10] | Select-Object -Property "ch", "CH1" | ConvertTo-Csv -QuoteFields False -Delimiter "`t" | Write-Output
Write-Output "--- ERD ---"
$processedData[0..10] | Select-Object -Property "ch", "CH2" | ConvertTo-Csv -QuoteFields False -Delimiter "`t" | Write-Output


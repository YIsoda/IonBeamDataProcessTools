#!usr/bin/env powershell
# https://github.com/YIsoda/IonBeamDataProcessTools

function ConvertTo-Simnra {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Path,
        # 入力された数のchannel数ごとに和をとって1つのchannel（ビン）にします
        [Parameter()][ValidateRange(1, 1000)][int]$BinWidth = 1,
        [Parameter()][ValidateRange(1, 100000)][int]$RbsMaxCh = 10000,
        [Parameter()][ValidateRange(1, 100000)][int]$ErdMaxCh = 10000
    )

    . $PSScriptRoot/ConvertToSimnra.ps1 -Path $Path -BinWidth $BinWidth -RbsMaxCh $RbsMaxCh -ErdMaxCh $ErdMaxCh
}

Export-ModuleMember ConvertTo-Simnra
<!-- # IonBeamDataProcessTools

イオンビーム測定データの形式変換などの中間処理用ツール（群）/ Tools for intermediate processing such as format conversion of ion beam measurement data -->


# ConvertFormatToSimnra

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/ConvertToSimnra?style=flat-square)](https://www.powershellgallery.com/packages/ConvertToSimnra/)

イオンビーム測定で得られた生データファイルをSIMNRAで読み込み可能なAscii形式（2列）に変換します。
Converts the file obtained from ion beam measurents to the ascii data format (two columns) SIMNRA can read.

## 動作

以下の形式のCSVファイルに対応しています。

<details><summary>入力ファイル形式と出力ファイル形式/Raw input file format and output format</summary>

### Input
```
[Header]
Memo,
Measurement mode,Live Time

...
...

[Data]
ch,CH1,CH2,CH3,CH4
0,0,0,0,0
1,0,0,0,0
2,0,0,0,0
3,0,0,0,0
...
4095,0,0,0,0

```

### Output

```csv
# ↓Lines beginning with a non-numeric character are ignored by SIMNRA.
ch	CH1
0	0
1	0
2	0
```

</details>

- ファイル内の `[Data]` 以降のカウント値をファイルに出力します。
- <!--既定では，-->CH1がRBSスペクトル，CH2がERDスペクトルとします。
- 出力ディレクトリ `Dat` を作成します。もとのファイル名にサフィックス `_rbs`，`_erd`（それぞれRBS（CH1），ERD（CH2））を付けた拡張子 `.dat` および元のファイル名と同じCSVファイルを作成します。
    - すでに同名のファイルがある場合も<!--既定では-->**上書き**されます。
      
      If a file with the same name already exists, it will be **overwritten**<!-- by default-->.

## 使用方法 / Usage

- 動作環境 System Requirements
    - [PowerShell 7](https://docs.microsoft.com/ja-jp/powershell/scripting/overview)（[インストール方法](https://docs.microsoft.com/ja-jp/powershell/scripting/install/installing-powershell-on-windows)，[GitHub](https://github.com/PowerShell/PowerShell)，[Microsoft Store](https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D)）が必須ですのでインストールしてください。
    
      Requires [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/overview) ([instalation](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows) / [GitHub](https://github.com/PowerShell/PowerShell) / [Microsoft Store](https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D)), so please install it.

- Installation (from [PowerShell Gallery](https://www.powershellgallery.com/packages/ConvertToSimnra/0.0.3) )
  ```powershell
  Install-Module -Name ConvertToSimnra -Scope CurrentUser
  ```

### 実行 / Execute the command

```powershell
ConvertTo-Simnra -Path path_to_file.csv
# yields `Dat/OriginalFileName_rbs.dat`, `Dat/OriginalFileName_erd.dat` and `Dat/OriginalFileName.csv`
```

## Options

オプションはすべて大文字小文字の区別をしません（case-insensitive）。[タブ補完（先頭数文字を入力して `tab` キー）](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_tab_expansion)を利用すると便利です。

### `-Path`: 必須／Required

測定装置により得られた生のCSVファイルへのパスを指定します。

Specify the path to the raw CSV file obtained by the instrument.

### `-BinWidth` (nonnegative integer)

チャネルを与えられた値*n*ごとに和をとってまとめます。全体のチャネル数は1/*n*となります。

Sum up the channels by summing them for each given value. The overall number of channels is 1/*n*.

<details><summary>例 Example</summary>
raw data

```csv
ch,CH1,CH2
0,0,0
1,4,3
2,6,4
3,10,5
4,12,8
5,15,10
...
```

processed data with option `-BinWidth 3`
```tsv
ch CH1 CH2
0 10 7
1 37 23
...
```

</details>

### `-RbsMaxCh` (nonnegative integer)

RBSデータで出力する最大のチャネルを指定します。

Specifies the maximum number of channels to output in RBS data.

### `-ErdMaxCh` (nonnegative integer)

ERDデータで出力する最大のチャネルを指定します。

Specifies the maximum number of channels to output in ERD data.

<!--
### `-OutputFolder`

出力先フォルダを指定します。

### `-Force`

出力先に同名のファイルがあった場合に上書きします。

### `-RbsChannel` (default: "CH1")

CH1～CH4のうちどのチャネルがRBS信号に対応するかを指定します

-->

## LICENSE

本スクリプトはMITライセンスで公開しますが，共同研究者の皆様が研究室内で再利用する場合は著作権表記なしで複製・変更の上利用していただいてかまいません。

This script is released under the MIT license, but may be reproduced without copyright notice for reuse by my collaborators in their laboratories.
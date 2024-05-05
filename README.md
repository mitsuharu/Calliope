Calliope
==

iOS向けの感熱紙印刷のアプリです


### What is Calliope?

> カリオペはギリシャ神話の9人のミューズの一人で、叙事詩と修辞のミューズとされています。文学と知識の保護者としての彼女の役割は、書物と印刷の普及に影響を与えると考えられます。

## 対象プリンター

- 本アプリで動作確認しているプリンタです

### ESPON

- [TM-P20Ⅱ](https://www.epson.jp/products/receiptprinter/tmp202/)
	- [開発キット Epson ePOS SDK](https://www.epson.jp/products/receiptprinter/develop/devkit.htm) を利用しています
	-  その SDK に対応していれば、他の同社製品でも利用できます

### Bluetooth機器 [^not-support-sdk]

- SUNMI 58mm サーマルプリンタ
	- SUNMI-TRP58-UWB

| Model | FW version | SUNMI APP version | Partner APP version | MiniApp version |
| :-: | :-: | :-: | :-: | :-: |
| NT212_S | 2.1.0 | 2.2.0 | 1.0.10 | 0.0.1 |

- SUNMI 80mm クラウドプリンタ
	- SUNMI-TRP80-ULWB
	- SUNMI 80mm キッチンプリンター
	- [https://www.sunmi.com/ja/80-kitchen-cloud-printer/](https://www.sunmi.com/ja/80-kitchen-cloud-printer/)

| Model | FW version | SUNMI APP version | Partner APP version | MiniApp version |
| :-: | :-: | :-: | :-: | :-: |
| NT311 | 2.1.0 | 2.13.0 |1.0.10 | 0.0.1 |
 
[^not-support-sdk]: SUNMI は Cloud Printer SDK for iOS を公開していますが、要件（80mm kitchen cloud printer, Model: NT31x, SUNMI APP Version: 2.19.0 or above device;）を満たしていないため、一般の Bluetooth で接続しました https://developer.sunmi.com/docs/en-US/xeghjk491/fdfeghjk535
 

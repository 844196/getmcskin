# getmcskin
[![](https://img.shields.io/travis/844196/getmcskin.svg?style=flat)](https://travis-ci.org/844196/getmcskin)
[![](http://img.shields.io/github/tag/844196/getmcskin.svg?style=flat)](https://github.com/844196/getmcskin/releases)
[![](http://img.shields.io/github/issues/844196/getmcskin.svg?style=flat)](https://github.com/844196/getmcskin/issues)
[![](http://img.shields.io/badge/license-MIT-red.svg?style=flat)](LICENSE)

![](http://38.media.tumblr.com/2f58b8cd8ab31e3dcf2c8a0a86bcbf1c/tumblr_nh4p5xqaFF1s7qf9xo1_1280.gif)

Minecraftのスキンからいい感じのアイコンを生成するシェルスクリプトです

## Required
`curl`, `jq`, `base64`, `convert` (ImageMagick)

## Usage
### Basic usages

```shellsession
$ getmcskin --help
Usage:
    getmcskin [optinos] username

Required:
    curl, jq, base64, ImageMagick

Argument:
    username        Minecraft Username

Options:
    -v, --version   Print version and exit successfully.
    -h, --help      Print this help and exit successfully.
    -s, --size      Specify the output image size. (default: 800)
    -o, --output    Specify the output path. (default: ./username.png)
```

```shellsession
$ pwd
/Users/s083027

$ getmcskin 844196
/Users/s083027/844196.png
```

```shellsession
$ getmcskin --size 400 --output ~/Downloads/hyousikinuko.png hyousikinuko
/Users/s083027/Downloads/hyousikinuko.png

$ identify -format "%w %h" ~/Downloads/hyousikinuko.png
400 400
```

### Additional usage

```shell
#!/bin/bash

users=('844196' 'hyousikinuko' 'mo_ri_mo_to')

for villager in "${users[@]}"
do
    sleep 30
    getmcskin "${villager}" | xargs open
done
```

### Return values

|戻り値|説明                                        |
|:----:|:-------------------------------------------|
|  0   |正常終了                                    |
| 255  |引数もしくはオプションに不備がある          |
|  2   |要求コマンドへのパスが通っていない          |
|  3   |指定されたサイズの値が不正である            |
|  4   |指定された出力パスが存在しない              |
|  5   |ネットワークに接続されていない              |
|  6   |`convert`（ImageMagick）が変換に失敗した    |
|  7   |`convert`（ImageMagick）が最終出力に失敗した|
| 204  |指定されたユーザーネームが存在しない        |
| 173  |短時間に何回も実行された                    |
|  1   |その他のエラー                              |

## License
[MIT](LICENSE)

## Author
Masaya Tk (<https://github.com/844196>)

## Thanks
唐突なコードレビューにも関わらず応えてくれた[sasairc](https://github.com/sasairc)さん、ありがとうございます

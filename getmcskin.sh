#!/bin/bash -e
#
#   @(#) Minecraftのスキンアイコンを取得
#
#   Required:
#       jq, imagemagick
#
#   Usage:
#       mc_skin <username>
#
#   Author:
#       844196 (@84____)
#
#   License:
#       MIT
#


# 一時ファイル作成
tmpfile=$(mktemp "/tmp/tmp.$[RANDOM*RANDOM]")
function _DeleteTmp() {
    [[ -n ${tmpfile} ]] && rm -f "${tmpfile}"
}
trap '_DeleteTmp;' EXIT
trap '_DeleteTmp; exit 1;' INT ERR


# スキン取得
USER_NAME="$1"
UUID=$(curl -s https://api.mojang.com/users/profiles/minecraft/${USER_NAME} | jq -r .id)
SKIN=$(curl -s https://sessionserver.mojang.com/session/minecraft/profile/${UUID} | jq -r .properties[].value | base64 -D | jq -r .textures.SKIN.url)

curl -o ${tmpfile} ${SKIN} >/dev/null 2>&1


# 変換
convert -crop 8x8+8+8 ${tmpfile} ${tmpfile}
convert -scale 800x800 ${tmpfile} ~/${USER_NAME}.png

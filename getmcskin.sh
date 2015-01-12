#!/bin/bash -e
#
#   @(#) Minecraftのスキンアイコンを取得
#
#   Author:
#       844196 (@84____)
#
#   License:
#       MIT
#


# usage
function usage() {
    cat <<EOF
Usage:
    ${0##*/} [-s size] [-o filename] <Username>

Required:
    curl, jq, base64, ImageMagick

Options:
    -h   このヘルプを出力します
    -s   出力される画像の大きさを指定します (default: 800)
    -o   出力するファイルを指定します (default: ~/<Username>.png)

ErrorCode:
     42  ネットワークに接続できません.
    173  時間を置いてから再度実行してください.
    204  指定されたユーザーネームは存在しません.
EOF
    exit 0
}


# error
function error() {
    echo "${0##*/}: ${1}" 1>&2
    exit "${2:-1}"
}


# get options
while getopts :s:o:h option
do
    case ${option} in
        'h' ) usage;;
        's' ) output_size=${OPTARG};;
        'o' ) output_name=${OPTARG};;
        \?  ) error "存在しないオプションです";;
        :   ) error "オプションの引数が足りません";;
    esac
done
shift $((OPTIND - 1))


# check require command
readonly require_command=('curl' 'jq' 'base64' 'convert')
for command in "${require_command[@]}"
do
    type "${command}" >/dev/null 2>&1 || error "次のコマンドが必要です: ${command}"
done


# get username
while read stdin
do
    set -- "${1:-${stdin}}"
done

if [ -n "${1}" ]; then
    readonly USERNAME="${1}"
else
    error "ユーザーネームが入力されていません"
fi


# check options
output_size="${output_size:-800}"
if expr "${output_size}" : '[1-9][0-9]*$' >/dev/null; then
    :
else
    error "画像の大きさは数値のみを入力してください"
fi

output_name="${output_name:-${HOME}/${USERNAME}.png}"
if [ -e "${output_name%/*}" ]; then
    :
else
    error "指定されたディレクトリは存在しません"
fi


# make tmpfile
readonly TMPDIR="${TMP:-/tmp}/${0##*/}.$$"
mkdir -p "${TMPDIR}"

function makeTmpFile() {
    local filename="${TMPDIR}/${1:-$RANDOM.tmp}"
    mktemp "${filename}"
}

trap 'rm -r ${TMPDIR}' 0


# get skin
function checkHttpCode() {
    local http_code="$(echo "${1}" | jq -r 'select(has("http_code")) | .http_code')"
    case "${http_code}" in
        '200' ) return 0;;
        '000' ) error "E42 (Network Error)" "42";;
        *     ) return "${http_code}";;
    esac
}

function getUUID() {
    local UUID_JSON=$(curl -s https://api.mojang.com/users/profiles/minecraft/"${USERNAME}" -w '{"http_code":"%{http_code}"}')
    if checkHttpCode "${UUID_JSON}"; then
        readonly UUID=$(echo "${UUID_JSON}" | jq -r 'select(has("id")) | .id')
    else
        error "E${?} (getUUID)" "${?}"
    fi
}; getUUID "${USERNAME}";

function getSkinUri() {
    local SKIN_JSON=$(curl -s https://sessionserver.mojang.com/session/minecraft/profile/"${UUID}" -w '{"http_code":"%{http_code}"}')
    if checkHttpCode "${SKIN_JSON}"; then
        local SKIN_URI=$(echo "${SKIN_JSON}" | jq -r 'select(has("properties")) | .properties[].value' | base64 -D | jq -r '.textures.SKIN.url')
        curl -s -o "$(makeTmpFile skin.png)" "${SKIN_URI}"
    else
        error "E${?} (getSkinUri)" "${?}"
    fi
}; getSkinUri;


# convert
function skinConvert() {
    convert -crop 8x8+8+8 "${TMPDIR}/skin.png" "${TMPDIR}/face.png"
    convert -crop 8x8+40+8 "${TMPDIR}/skin.png" "${TMPDIR}/hair.png"
    convert "${TMPDIR}/face.png" "${TMPDIR}/hair.png" -composite "${TMPDIR}/head.png"
    convert -scale x"${output_size}" "${TMPDIR}/head.png" "${output_name}"
}; skinConvert && echo "${output_name}";

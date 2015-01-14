#!/bin/bash
#
#   @(#) Minecraftのスキンアイコンを取得
#
#   Author:
#       844196 (@84____)
#
#   License:
#       MIT
#


# initialize
## option
set -u
set -e

## about me
readonly ME="${0##*/}"
readonly VERSION="0.3"

## usage
function usage() {
    cat <<-EOF 1>&2
	Usage:
	    ${ME} [optinos] username
	
	Required:
	    curl, jq, base64, ImageMagick
	
	Argument:
	    username        Minecraft Username
	
	Options:
	    -v, --version   Print version and exit successfully.
	    -h, --help      Print this help and exit successfully.
	    -s, --size      Specify the output image size. (default: 800)
	    -o, --output    Specify the output path. (default: ./username.png)
	EOF
    return 0
}

## error
function error() {
    echo "${ME}: ${1}" 1>&2
    exit "${2:-1}"
}

## temporary
readonly TMPDIR="${TMP:-/tmp}/${ME}.$$"
mkdir -p "${TMPDIR}"
trap 'rm -r ${TMPDIR}' 0
function makeTmpFile() {
    local filename="${TMPDIR}/${1:-$RANDOM.tmp}"
    mktemp "${filename}"
    return 0
}

## check require command
required_command=('curl' 'jq' 'base64' 'convert')
for command in "${required_command[@]}"
do
    type "${command}" >/dev/null 2>&1 || error "requires command -- ${command}" "2"
done


# get and check argument, options
## get option
for OPTIONS in "${@-}"
do
    case "${OPTIONS}" in
        '-h'|'--help' )
            usage
            exit 0
            ;;
        '-v'|'--version' )
            echo "${VERSION}" 1>&2
            exit 0
            ;;
        '-s'|'--size' )
            if [[ -z "${2-}" ]] || [[ "${2-}" =~ ^-+ ]]; then
                error "option requires an argument -- '${1}'" "-1"
            fi
            output_size="${2}"
            shift 2
            ;;
        '-o'|'--output' )
            if [[ -z "${2-}" ]] || [[ "${2-}" =~ ^-+ ]]; then
                error "option requires an argument -- '${1}'" "-1"
            fi
            output_path="${2}"
            shift 2
            ;;
        '--debug' )
            echo "${ME} ${VERSION} debug mode"
            set -x
            shift 1
            ;;
        -* )
            error "illegal option -- '${1}'" "-1"
            ;;
        * )
            if [[ -n "${1-}" ]] && [[ ! "${1-}" =~ ^-+ ]]; then
                args+=( "${1}" )
                shift 1
            fi
            ;;
    esac
done

## get username
while read -t 1 stdin
do
    : "${args[0]:=${stdin}}"
done
if [[ -n "${args[0]-}" ]]; then
    readonly username="${args[0]}"
else
    error "invaild argument" "-1"
fi

## check options
### output size
readonly output_size="${output_size:-800}"
if ! [[ "${output_size}" =~ [1-9][0-9]*$ ]]; then
    error "invaild option -- 'output_size'" "3"
fi

### output path
output_path=${output_path:-./${username}.png}
output_filename="${output_path##*/}"
output_directory="$(dirname "${output_path}")"
if [[ -e "${output_directory}" ]]; then
    output_directory="$(
        cd "${output_directory}"
        pwd
    )"
    readonly output_path="${output_directory%/}/${output_filename}"
else
    error "invaild option -- 'output_path'" "4"
fi


# get skin
## check http status code
function checkHttpStatusCode() {
    local http_status_code="$(
        echo "${1}" |
        jq -r 'select(has("http_status_code")) | .http_status_code'
    )"
    case "${http_status_code}" in
        '200' )
            return 0
            ;;
        '000' )
            return 5
            ;;
        * )
            return "${http_status_code}"
            ;;
    esac
}

## get UUID
function getUuid() {
    local uuid_json="$(
        curl -s https://api.mojang.com/users/profiles/minecraft/"${1}" \
        -w '{"http_status_code":"%{http_code}"}'
    )"
    if checkHttpStatusCode "${uuid_json}"; then
        uuid="$(
            echo "${uuid_json}" |
            jq -r 'select(has("id")) | .id'
        )"
    else
        error "internal error -- 'getUuid()'" "${?}"
    fi
    return 0
}; getUuid "${username}";

## get skin URI and download
function getSkinUri() {
    local skin_json="$(
        curl -s https://sessionserver.mojang.com/session/minecraft/profile/"${1}" \
        -w '{"http_status_code":"%{http_code}"}'
    )"
    if checkHttpStatusCode "${skin_json}"; then
        local skin_uri="$(
            echo "${skin_json}"                                     |
            jq -r 'select(has("properties")) | .properties[].value' |
            base64 -D                                               |
            jq -r '.textures.SKIN.url'
        )"
        curl -s -o "$(makeTmpFile skin.png)" "${skin_uri}"
    else
        error "internal error -- 'getSkinUri()'" "${?}"
    fi
    return 0
}; getSkinUri "${uuid}";


## convert
function skinConvert() {
    convert -crop 8x8+8+8 "${TMPDIR}/skin.png" "$(makeTmpFile face.png)" && :
        [[ "${?}" -ne "0" ]] && error "internal error -- 'skinConvert()'" "6"
    convert -crop 8x8+40+8 "${TMPDIR}/skin.png" "$(makeTmpFile hair.png)" && :
        [[ "${?}" -ne "0" ]] && error "internal error -- 'skinConvert()'" "6"
    convert "${TMPDIR}/face.png" "${TMPDIR}/hair.png" -composite "$(makeTmpFile head.png)" && :
        [[ "${?}" -ne "0" ]] && error "internal error -- 'skinConvert()'" "6"
    convert -scale x"${output_size}" "${TMPDIR}/head.png" "${output_path}" && :
        [[ "${?}" -ne "0" ]] && error "internal error -- 'skinConvert()'" "7"
    return 0
}; skinConvert && echo "${output_path}" && exit 0;

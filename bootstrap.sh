#!/bin/sh

set -e
set -u

CWD=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
SCRIPT_NAME="$(basename -- "${0}")"

######################################################################
# Colors
######################################################################

NO_COLOR="$(tput sgr0 2>/dev/null || printf '\033[m')"
BOLD="$(tput bold 2>/dev/null || printf '\033[1m')"
DIM="$(tput dim 2>/dev/null || printf '\033[2m')"
ITALIC="$(tput sitm 2>/dev/null || printf '\033[3m')"
UNDERLINE="$(tput smul 2>/dev/null || printf '\033[4m')"

BLACK="$(tput setaf 0 2>/dev/null || printf '\033[38;5;0m')"
RED="$(tput setaf 1 2>/dev/null || printf '\033[38;5;1m')"
GREEN="$(tput setaf 2 2>/dev/null || printf '\033[38;5;2m')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '\033[38;5;3m')"
BLUE="$(tput setaf 4 2>/dev/null || printf '\033[38;5;4m')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '\033[38;5;5m')"
CYAN="$(tput setaf 6 2>/dev/null || printf '\033[38;5;6m')"
WHITE="$(tput setaf 7 2>/dev/null || printf '\033[38;5;7m')"

BG_BLACK="$(tput setab 0 2>/dev/null || printf '\033[48;5;0m')"
BG_RED="$(tput setab 1 2>/dev/null || printf '\033[48;5;1m')"
BG_GREEN="$(tput setab 2 2>/dev/null || printf '\033[48;5;2m')"
BG_YELLOW="$(tput setab 3 2>/dev/null || printf '\033[48;5;3m')"
BG_BLUE="$(tput setab 4 2>/dev/null || printf '\033[48;5;4m')"
BG_MAGENTA="$(tput setab 5 2>/dev/null || printf '\033[48;5;5m')"
BG_CYAN="$(tput setab 6 2>/dev/null || printf '\033[48;5;6m')"
BG_WHITE="$(tput setab 7 2>/dev/null || printf '\033[48;5;7m')"

######################################################################
# Print
######################################################################

# Usage: print_info <message>
# Description: outputs a colorized, where applicable, info message
print_info() {
  printf "%s\n" "${CYAN}[*]${NO_COLOR} $*"
}

# Usage: print_warn <message>
# Description: outputs a colorized, where applicable, warning message
print_warn() {
  printf "%s\n" "${YELLOW}[!] $*${NO_COLOR}"
}

# Usage: print_error <message>
# Description: outputs a colorized, where applicable, error message
print_error() {
  printf "%s\n" "${RED}[x] $*${NO_COLOR}" >&2
}

# Usage: print_critical
# Description: outputs a colorized, where applicable, pre-defined critical message
print_critical() {
  print_error "Something unexpected has happened, please contact the maintainer"
}

# Usage: print_success <message>
# Description: outputs a colorized, where applicable, success message
print_success() {
  printf "%s\n" "${GREEN}[✓]${NO_COLOR} $*"
}

# Usage: print_prompt <question> [<default choice>]
# Description: prompts for input to y or n, defaults to n, unless passed
# Return: 0 if y or 1 if n
# Note: use of `local` is not, technically, POSIX compliant
print_prompt() {
  if [ ${FORCE:-0} -eq 1 ]; then
    return 0
  fi

  local _yes="y"
  local _no="N"
  local _rc=0
  local _answer=

  if [ "${2}" != "${2#[Yy]}" ]; then
    _yes="Y"
    _no="n"
  fi

  printf "%s %s? [%s/%s] " \
    "${MAGENTA}[?]${NO_COLOR}" \
    "${1}" \
    "${BOLD}${_yes}${NO_COLOR}" \
    "${BOLD}${_no}${NO_COLOR}"

  read -r _answer </dev/tty
  _rc=$?

  if [ $_rc -ne 0 ]; then
    print_error "Unable to read from prompt"
    return 1
  fi

  if [ -z "${_answer-}" ] \
    && [ "${_yes}" = "Y" ] \
    || [ "${_answer}" != "${_answer#[Yy]}" ]; then

    return 0
  else
    return 1
  fi
}

######################################################################
# Environment
######################################################################

# originally taken from https://heptapod.host/flowblok/shell-startup/-/blob/branch/default/.shell/env_functions

# Usage: indirect_expand PATH -> $PATH
# Description: outputs, if matched, env variable value
# Note: use of `local` is not, technically, POSIX compliant
indirect_expand () {
  local _path="${1:-PATH}"

  env | sed -n "s/^${_path}=//p"
}

# Usage: remove_from_path /path/to/bin [PATH]
# Description: to remove ~/bin from $PATH `remove_from_path ~/bin ${PATH}`
# Note: use of `local` is not, technically, POSIX compliant
remove_from_path () {
  local IFS=':'
  local _newpath=
  local _dir=
  local _var=${2:-PATH}

  # bash has ${!var}, but this is not portable
  for _dir in $(indirect_expand "${_var}"); do
    IFS=''
    if [ "${_dir}" != "${1}" ]; then
      _newpath=${_newpath}:${_dir}
    fi
  done

  export "${_var}=${_newpath#:}"
}

# Usage: prepend_to_path /path/to/bin [PATH]
# Description: to prepend ~/bin to $PATH `prepend_to_path ~/bin ${PATH}`
# Note: use of `local` is not, technically, POSIX compliant
prepend_to_path () {
  # if the path is already in the variable,
  # remove it so we can move it to the front
  remove_from_path "${1}" "${2}"

  #[ -d "${1}" ] || return
  local _var="${2:-PATH}"
  local _value=$(indirect_expand "${_var}")

  export "${_var}=${1}${_value:+:${_value}}"
}

# Usage: append_to_path /path/to/bin [PATH]
# Description: to append ~/bin to $PATH `append_to_path ~/bin ${PATH}`
# Note: use of `local` is not, technically, POSIX compliant
append_to_path () {
  remove_from_path "${1}" "${2}"
  #[ -d "${1}" ] || return

  local _var=${2:-PATH}
  local _value=$(indirect_expand "${_var}")

  export "${_var}=${_value:+${_value}:}${1}"
}

# Usage: get_os_name
# Description: gets and lcase the os name; normalizes cygwin, msys, mingw 
# Outputs: the lcase os name
# Note: use of `local` is not, technically, POSIX compliant
get_os_name() {
  local _os_name="${OS_NAME:-"$(uname -s | tr '[:upper:]' '[:lower:]')"}"

  case "${_os_name}" in
    msys_nt*) _os_name="win" ;;
    cygwin_nt*) _os_name="win" ;;
    mingw*) _os_name="win" ;;
  esac

  printf "%s" "${_os_name}"
}

# Usage: get_os_arch
# Description: gets and lcase the os architecture; normalizes
# Outputs: the  lcase os architecture
# Note: use of `local` is not, technically, POSIX compliant
get_os_arch() {
  local _arch="${ARCH:-"$(uname -m | tr '[:upper:]' '[:lower:]')"}"

  case "${_arch}" in
    amd64*) _arch="x86_64" ;;
    armv*) _arch="arm" ;;
    arm64*) _arch="aarch64" ;;
  esac

  # uname may misreport 32-bit as 64-bit OS
  if [ "${_arch}" = "x86_64" ] && [ $(getconf LONG_BIT) -eq 32 ]; then
    _arch="i686"
  elif [ "${_arch}" = "aarch64" ] && [ $(getconf LONG_BIT) -eq 32 ]; then
    _arch="arm"
  fi 

  printf "%s" "${_arch}"
}

######################################################################
# Utility
######################################################################

# Usage: is_sourced
# Description: attempts to determine if script is sourced or called directly
# Return: 0 if called directly
#         1 if sourced
# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
# Note: use of `local` is not, technically, POSIX compliant
is_sourced() {
  ZSH_EVAL_CONTEXT="${ZSH_EVAL_CONTEXT-}"
  KSH_VERSION="${KSH_VERSION-}"
  BASH_VERSION="${BASH_VERSION-}"

  local _sourced=0

  if [ -n "${ZSH_EVAL_CONTEXT}" ]; then
    case "${ZSH_EVAL_CONTEXT}" in *:file) _sourced=1;; esac
  elif [ -n "${KSH_VERSION}" ]; then
    [ "$(cd $(dirname -- $0) \
      && pwd -P)/$(basename -- $0)" != "$(cd $(dirname -- ${.sh.file}) \
      && pwd -P)/$(basename -- ${.sh.file})" ] \
      && _sourced=1
  elif [ -n "${BASH_VERSION}" ]; then
    (return 0 2>/dev/null) && _sourced=1
  else # All other shells: examine $0 for known shell binary filenames
    # Detects `sh` and `dash`; add additional shell filenames as needed.
    case ${0##*/} in sh|dash) _sourced=1;; esac
  fi

  [ $_sourced -eq 1 ] && return 0 || return 1
}

# Usage: safe_source <file_path>
# Description: checks if file is readable, before sourcing
safe_source() {
  if [ -r "${1}" ]; then
    # shellcheck disable=SC1090
    . "${1}"
  fi
}

# Usage: check_if_sourced
# Description: check if sourced or not, print error and exit if not sourced 
check_if_sourced() {
  if ! is_sourced; then
    print_error "This file should not be called directly!"
    exit 1
  fi
}

# Usage: create_dir <dir>
# Description: creates the directory, if it doesn't exist
create_dir() {
  mkdir -p "${1}"
}

# Usage: has_command <command>
# Description: checks if the command is in the current PATH
# Return: 0, if found in PATH
#         1, if not found in PATH
has_command() {
  command -v "${1}" 1>/dev/null 2>&1
}

# Usage: elevate_cmd <command>
# Description: attempts, using `sudo`, to elevate the provided command
# Return: 0, if success
#         1, if unable to elevate
# Note: use of `local` is not, technically, POSIX compliant
# TODO: very rudimentary/naive, needs improvement
elevate_cmd() {
  local _euid=${EUID:-$(id -u)}

  if [ $_euid -gt 0 ] && ! has_command sudo; then
    print_error "Non-root user and no sudo-like program"
    return 1
  elif [ $_euid -gt 0 ]; then
    print_info "Running: sudo -v ${@}"

    if ! sudo -v $@; then
      print_error "Superuser privileges not granted"
      return 1
    fi
  else
    # already running as an elevated user, just run the command
    $@
  fi
}

# Usage: http_get <URL> [<file>]
# Description: HTTP GET a URL
# Return: 0 if success, with the file downloaded
# Return: 1 if no URL provided, a HTTP request command does not exist,
#         or the request fails
# Note: use of `local` is not, technically, POSIX compliant
http_get() {
  local url="${1}"
  local file="${2:-"$(basename "${url}")"}"
  local rc=0

  if [ -z "${url-}" ]; then
    print_error "Usage: http_get <url> [<fielpath>]"
    return 1
  fi

  if has_command curl; then
    cmd="curl --fail --silent --location --output ${file} ${url}"
  elif has_command wget; then
    cmd="wget --quiet --output-document=${file} ${url}"
  elif has_command fetch; then
    cmd="fetch --quiet --output=${file} ${url}"
  else
    print_error "No HTTP request command found (curl, wget, fetch)"
    return 1
  fi

  "${cmd}" && return 1 || rc=$?

  print_error "Failed to get URL (exit code ${rc}): ${BLUE}${cmd}${NO_COLOR}"
  return $rc
}

######################################################################
# XDG
######################################################################

# Usage: create_xdg_base_dir
# Description: creates the dir and sets perms, if the dir does not exist
create_xdg_base_dir() {
  # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
  if [ ! -d "${1}" ]; then 
    create_dir "${1}"
    chmod 0700 "${1}"
  fi
}

# Usage: create_xdg_base_dirs
# Description: creates the XDG dirs and env variables
create_xdg_base_dirs() {
  # https://www.freedesktop.org XDG ENV variable declarations
  # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

  print_info "Setting up XDG base dir structure"

  create_xdg_base_dir "${XDG_DATA_HOME:-"${HOME}/.local/share"}"
  create_xdg_base_dir "${XDG_CONFIG_HOME:-"${HOME}/.config"}"
  create_xdg_base_dir "${XDG_STATE_HOME:-"${HOME}/.local/state"}"
  create_xdg_base_dir "${XDG_CACHE_HOME:-"${HOME}/.cache"}"

  print_success "XDG base dir structure verified/created"
}

######################################################################
# Required Files
######################################################################

# Usage: cleanup_temp_dir <temp_dir> [<signal>]
# Description: cleans up the given temp dir on matched signal
# Note: use of `local` is not, technically, POSIX compliant
cleanup_temp_dir() {
  local _temp_dir="${1}"
  local _signal=$2

  trap - EXIT

  if [ -d "${_temp_dir}" ]; then rm -rf "${_temp_dir}"; fi
  if [ -n "${_signal}" ]; then trap - $_signal; kill -${_signal} $$; fi
}

# Usage: make_temp_dir <ouput>
# Description: creates a temp folder to work in
# Output: sets the temp dir to the provided <output>
# Return: 0, if success and 1, if error
# Note: use of `local` is not, technically, POSIX compliant
make_temp_dir() {
  local _output=$1
  local _pid=$$
  local _tmp_dir="${TMPDIR:-"/tmp"}"
  _tmp_dir="${_tmp_dir%/}"

  local _name="jwinn-os-bootstrap"
  local _dir_name="${_tmp_dir}/${_name}-XXXXXX"

  # see if mktemp command exists, otherwise fall back to POSIX(y) way
  # TODO: catch errors and return code
  if has_command mktemp; then
    _tmp_dir="$(mktemp -d "${_dir_name}")" || return 1
  else
    # relatively naive attempt at unique name
    local _seq="$(awk 'BEGIN {srand(); printf "%d\n", rand() * 10^8}')"
    _tmp_dir="${_tmp_dir}/${_name}-${_pid}-${_seq}"
    umask 0177
    create_dir "${_tmp_dir}"
    if [ ! -d "${_tmp_dir}" ]; then return 1; fi
  fi

  # https://unix.stackexchange.com/questions/29851/shell-script-mktemp-whats-the-best-method-to-create-temporary-named-pipe
  trap "cleanup_temp_dir '${_tmp_dir}'" EXIT
  trap "cleanup_temp_dir '${_tmp_dir}' HUP" HUP
  trap "cleanup_temp_dir '${_tmp_dir}' TERM" TERM
  trap "cleanup_temp_dir '${_tmp_dir}' INT" INT

  eval "$_output=\$_tmp_dir"
  return 0
}

# Usage: get_required_files <base_dir> <base_url> <output>
# Description: downloads requisite files
# Output: sets provided <output> to the working folder
# Return: 0 if files downloaded to temp dir, or the files are existing
#         1 if an error occurs in any process
# Note: use of `local` is not, technically, POSIX compliant
get_required_files() {
  local _dest_file= _file= _url=
  local _include_dir="includes"
  local _temp_dir="${1}"
  local _base_url="${2}"
  local _output=$3
  local _include_files="install.inc uninstall.inc Brewfile"
  _include_files="${_include_files} asdf.inc homebrew.inc nix.inc"
  _include_files="${_include_files} chezmoi.inc dotfiles.inc nerdfonts.inc"
  _include_files="${_include_files} powerlevel10k.inc starship.inc"

  # TODO: make more robust
  if [ -d "${_temp_dir}/${_include_dir}" ]; then
    for _file in $_include_files; do
      _dest_file="${_temp_dir}/${_include_dir}/${_file}"

      if [ ! -f "${_dest_file}" ]; then
        printf "%s\n" "Required file not found: ${_dest_file}"
        return 1
      fi
    done
  else
    # create a temp dir to use
    make_temp_dir "_temp_dir"
    create_dir "${_temp_dir}/${_include_dir}"

    printf "%s%s\n" "Required files not found locally. " \
      "Downloading required files to: ${_temp_dir}"

    # download required files
    for _file in $_include_files; do
      _dest_file="${_temp_dir}/${_include_dir}/${_file}"

      if [ ! -f "${_dest_file}" ]; then
        _url="${_base_url}/${_include_dir}/${_file}"

        if ! http_get "${_url}" "${_dest_file}"; then
          printf "%s\n" "Failed to get required file: ${_url}"
          return $?
        fi
      fi
    done
  fi

  eval "$_output=\$_temp_dir"
  return 0
}

######################################################################
# Main
######################################################################

# defaults
ARCH="${ARCH:-"$(get_os_arch)"}"
BASE_URL="${BASE_URL:-"https://github.com/jwinn/os-bs/raw/branch/main"}"
COMMAND="${COMMAND-}"
FORCE=0
OS_NAME="${OS_NAME:-"$(get_os_name)"}"
WORK_DIR=

usage() {
  printf "%s\n" \
    "Usage: ${SCRIPT_NAME} [options]" \
    "" \
    "Downloads requisite files to perform install or removal of basic OS programs"

  printf "\n%s\n" "${UNDERLINE}Options${NO_COLOR}"
  printf "\t%s\n\t\t%s\n\n" \
    "-a, --arch" "Override the architecture deterined by the script [${ARCH}]" \
    "-h, --help" "Display this help message" \
    "-i, --install" "Installs basic OS-specific programs" \
    "-n, --name" "Override the OS name deterined by the script [${OS_NAME}]" \
    "-u, --uninstall" "Uninstalls what was installed, with caveats" \
    "-y, --yes" "Answer [y]es to any prompts in the process"
}

# Usage: main
# Description: ensures required files available
#              launches provided command--passing certain arguments on
#              defaults to `install`, if no arg provided
main() {
  # export XDG vars for included scripts
  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
  export XDG_DATA_HOME="${XDG_DATA_HOME:-"${HOME}/.local/share"}"

  print_info "Getting required script files"
  if ! get_required_files "${CWD}" "${BASE_URL}" "WORK_DIR"; then
    print_critical "Failed to get/locate required files"
    exit 1
  fi

  WORK_INCLUDES_DIR="${WORK_DIR}/includes"

  # source base include file
  safe_source "${WORK_INCLUDES_DIR}/base.inc"

  case "${COMMAND}" in
    install)
      safe_source "${WORK_INCLUDES_DIR}/install.inc"

      # determine OS to install to and call the command
      case "${OS_NAME}" in
        darwin) install_macos; return $? ;;
        #freebsd) install_freebsd; return $? ;;
        #linux) install_linux; return $? ;;
        *)
          print_error "${OS_NAME} is currently not supported"
          return 1
          ;;
      esac
      ;;
    uninstall)
      safe_source "${WORK_INCLUDES_DIR}/uninstall.inc"

      # determine OS to uninstall to and call the command
      case "${OS_NAME}" in
        darwin) uninstall_macos; return $? ;;
        #freebsd) uninstall_freebsd; return $? ;;
        #linux) uninstall_linux; return $? ;;
        *)
          print_error "${OS_NAME} is currently not supported"
          return 1
          ;;
      esac
      ;;
    *)
      usage
      return 1
      ;;
  esac
}

# parse argv
while [ $# -gt 0 ]; do
  case "${1}" in
    -i | --install)
      COMMAND="install"
      shift 1
      ;;
    -u | --uninstall)
      COMMAND="uninstall"
      shift 1
      ;;

    -a | --arch)
      ARCH="${2}"
      shift 2
      ;;
    -a=* | --arch=*)
      ARCH="${1#*=}"
      shift 1
      ;;

    -n | --name)
      OS_NAME="${2}"
      shift 2
      ;;
    -n=* | --name=*)
      OS_NAME="${1#*=}"
      shift 1
      ;;

    -y | --yes)
      FORCE=1
      shift 1
      ;;

    -h | --help)
      usage
      exit
      ;;

    --)
      break
      ;;

    *)
      print_error "Unknown option provided: ${1}"
      usage
      exit 1
      ;;
  esac
done

# call main
main || exit $?

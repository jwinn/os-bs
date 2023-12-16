# shellcheck shell=sh

# TODO: will just error if base.inc was not sourced before
check_if_sourced

BREW_PREFIX="${BREW_PREFIX-}"
BREW_FORMULAE="${BREW_FORMULAE:-"atuin bottom emacs elvish"}"
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD"

# Usage: get_homebrew_prefix
# Description: naively checks for known homebrew install locations
# Outputs: the homebrew install location, if found
# Note: use of `local` is not, technically, POSIX compliant
get_homebrew_prefix() {
  local _path=

  if has_command brew; then
    _path="$(brew --prefix)"
  elif [ -n "${BREW_PREFIX}" ]; then
    _path="${BREW_PREFIX}"
  elif [ -x "/opt/homebrew/bin/brew" ]; then
    _path="/opt/homebrew"
  elif [ -x "${XDG_CONFIG_HOME}/brew/bin/brew" ]; then
    _path="${XDG_CONFIG_HOME}/brew"
  elif [ -x "${HOME}/.brew/bin/brew" ]; then
    _path="${HOME}/.brew"
  fi

  printf "%s" "${_path}"
}

# Usage: prepend_homebrew_to_path
# Description: attempts to prepend Hombrew bin to PATH
# Return: 0, if Homebrew bin in PATH
#         1, if an error occurs
# Note: use of `local` is not, technically, POSIX compliant
prepend_homebrew_to_path() {
  local _prefix="$(get_homebrew_prefix)"

  if has_command brew; then
    return 0
  fi

  print_warn \
    "Homebrew appears to be installed at: ${BOLD}${_prefix}${NO_COLOR}"
  print_warn \
    "However, its command is not found in: ${BOLD}${PATH}${NO_COLOR}"
  print_warn "Attempting to prepend to PATH"
  prepend_to_path "${_prefix}/bin"

  # check again
  if ! has_command brew; then
    print_error "Homebrew command still not found in: ${PATH}"
    return 1
  fi

  return 0
}

# Usage: install_homebrew
# Description: installs Homebrew, if not found
# Return: 0 if installed successfully, or already installed
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
install_homebrew() (
  local _prefix="$(get_homebrew_prefix)"

  # check if Homebrew already installed
  if has_command brew; then
    print_info \
      "Homebrew already installed at: ${BOLD}${_prefix}${NO_COLOR}"
    return 0
  fi

  # attempt to prepend brew command to PATH
  if [ -n "${_prefix}" ] && ! prepend_homebrew_to_path; then
    print_critical && return 1
  fi

  # check for required commands
  if ! has_command bash; then
    print_error \
      "bash is required and not found in: ${BOLD}${PATH}${NO_COLOR}"
    return 1
  fi
  if ! has_command curl; then
    print_error \
      "curl is required and not found in: ${BOLD}${PATH}${NO_COLOR}"
    return 1
  fi

  print_info "Installing Homebrew"

  if /bin/bash -c "$(curl -fsSL ${BREW_URL}/install.sh)"; then
    print_success "Homebrew installed at: ${BOLD}${_prefix}${NO_COLOR}"

    if ! has_command brew && ! prepend_homebrew_to_path; then
      print_critical
      return 1
    fi

    print_info "Updating Homebrew"
    brew update
    brew upgrade

    for _formula in $BREW_FORMULAE; do
      print_info "Installing ${_formula} formula"

      if brew install $_formula; then
        print_success "${_formula} formula installed"
      else
        print_error "${_formula} formula not installed"
      fi
    done

    print_info "Cleaning up Homebrew"
    brew cleanup -s
    brew doctor

    return 0
  else
    print_error "Homebrew failed to install"
    return 1
  fi
)

# Usage: uninstall_homebrew
# Description: uninstalls Homebrew, if found
# Return: 0 if uninstalled successfully, or already uninstalled
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
uninstall_homebrew() {
  local _prefix="$(get_homebrew_prefix)"

  # check if Homebrew installed
  if ! has_command brew && [ ! -d "${_prefix}" ]; then
    print_info "Homebrew cannot be found at: ${_prefix}"
    return 0
  fi

  print_info "Uninstalling Homebrew"

  if /bin/bash -c "$(curl -fsSL ${BREW_URL}/uninstall.sh)"; then
    print_success "Homebrew uninstalled"
    return 0
  fi

  print_error "Failed to uninstall Homebrew"
  return 1
}

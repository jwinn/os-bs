# shellcheck shell=sh

DOTFILES_REPO="https://github.com/jwinn/dotfiles.git"
DOTFILES_URL="https://raw.githubusercontent.com/jwinn/dotfiles/main"

# Usage: install_chezmoi
# Description: installs chezmoi, if not found
# Return: 0 if installed successfully, or already installed
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
install_chezmoi() {
  if ! has_command git; then
    print_error "git is required and not found in: ${PATH}"
    return 1
  fi

  if ! has_command curl; then
    print_error "curl is required and not found in: ${PATH}"
    return 1
  fi

  if ! has_command chezmoi; then
    print_info "chezmoi not found, installing and applying dotfiles"
    sh -c "$(curl -fsSL ${DOTFILES_URL}/bootstrap.sh)" || return $? 
    print_success "chezmoi installed and applied from: ${DOTFILES_REPO}"
  # TODO: improve check for existing dotfiles
  elif [ -d "${HOME}/.config/shell" ]; then
    print_info "dotfiles already appear to be installed"
    return 0
  else
    print_info "chezmoi installed, but dotfiles do not appear to be"
    chezmoi init --apply --verbose "${DOTFILES_REPO}"
    print_success "chezmoi applied from: ${DOTFILES_REPO}"
  fi

  return 0
}

# Usage: uninstall_chezmoi
# Description: uninstalls chezmoi, if found
# Return: 0 if uninstalled successfully, or already uninstalled
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
uninstall_chezmoi() {

  print_error "Not implemented" && return 1

  # check if chezmoi installed
  if ! has_command chezmoi; then
    print_info "chezmoi cannot be found in: ${PATH}"
    return 0
  fi

  print_info "Uninstalling chezmoi"

  return 0
}

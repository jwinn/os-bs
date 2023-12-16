# shellcheck shell=sh

# TODO: will just error if base.inc was not sourced before
check_if_sourced

# Usage: install_nix
# Description: installs nix, if not found
# Return: 0 if installed successfully, or already installed
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
install_nix() (
  # check if nix already installed
  if has_command nix-env; then
    print_info \
      "nix already installed at: $(command -v nix-env)"
    return 0
  fi

  # check for required commands
  if ! has_command curl; then
    print_error \
      "curl is required and not found in: ${PATH}"
    return 1
  fi

  print_info "Installing nix"

  #if /bin/bash -c "$(curl -fsSL ${BREW_URL}/install.sh)"; then
  #  print_success "nix installed at: $(command -v nix-env)"

  #  if ! has_command nix-env; then
  #    print_critical
  #    return 1
  #  fi

  #  return 0
  #else
  #  print_error "nix failed to install"
  #  return 1
  #fi
)

# Usage: uninstall_nix
# Description: uninstalls nix, if found
# Return: 0 if uninstalled successfully, or already uninstalled
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
uninstall_nix() {
  # check if nix already installed
  if ! has_command nix-env; then
    print_info "nix cannot be found in: ${PATH}"
    return 0
  fi

  print_info "Uninstalling nix"

  #if /bin/bash -c "$(curl -fsSL ${BREW_URL}/uninstall.sh)"; then
  #  print_success "nix uninstalled"
  #  return 0
  #fi

  print_error "Failed to uninstall nix"
  return 1
}

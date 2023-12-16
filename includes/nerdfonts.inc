# shellcheck shell=sh

NERD_URL="https://github.com/ryanoasis/nerd-fonts"
NERD_DEST="${XDG_CONFIG_HOME}/nerd-fonts"
NERD_FONTS="${NERD_FONTS:-"DroidSansMono FiraCode Hack Meslo"}"

# Usage: install_nerdfonts
# Description: installs Nerd Fonts, if not found
# Return: 0 if installed successfully, or already installed
#         1, if required commands missing, or an error occurs
# Note: use of `local` is not, technically, POSIX compliant
install_nerdfonts() {
  if ! has_command git; then
    print_error "git is required and not found in: ${PATH}"
    return 1
  fi

  if [ -d "${NERD_DEST}" ]; then
    print_info "Nerd Font repo already retrieved to: ${NERD_DEST}"
    return 0
  fi

  if git clone --depth=1 "${NERD_URL}" "${NERD_DEST}"; then
    print_info "Nerd Font repo retrieved: ${NERD_DEST}"
    print_info "Installing Nerd Fonts: ${NERD_FONTS}"
    if cd "${NERD_DEST}" && ./install.sh ${NERD_FONTS} && cd -; then
      print_success "Nerd Fonts installed"
      return 0
    else
      print_error "Unable to install Nerd Fonts: ${NERD_FONTS}"
      return 1
    fi
  fi

  print_error "Unable to retrieve Nerd Font repo from: ${NERD_URL}"
  return 1
}

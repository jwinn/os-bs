# shellcheck shell=sh

# TODO: will just error if base.inc was not sourced before
check_if_sourced

DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/projects/github/jwinn/dotfiles"}"
DOTFILES_URI="${DOTFILES_URI:-"https://github.com/jwinn/dotfiles"}"

# Usage: install_dotfiles
# Description: attempts to retrieve dotfiles from source repo and install
install_dotfiles() {
  if ! has_command git; then
    print_error "git not found in: ${PATH}"
    return 1
  fi

  if [ -d "${DOTFILES_DIR}" ]; then
    print_info "dotfiles repo already exists: ${DOTFILES_DIR}"
    if print_prompt "Would you like to update the repo" "y"; then
      cd "${DOTFILES_DIR}" && git pull && cd -
      return $?
    fi
    return 0
  fi

  print_info "Cloning ${DOTFILES_URI} into: ${DOTFILES_DIR}"

  if git clone ${DOTFILES_URI} "${DOTFILES_DIR}"; then
    print_success "dotfiles retreived, via git, at: ${DOTFILES_DIR}"

    print_info "Installing dotfiles for user: ${USER}"
    sh "${DOTFILES_DIR}/install.sh"
  fi
}

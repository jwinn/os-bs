# shellcheck shell=sh

check_if_sourced

# Usage: uninstall_freebsd
#uninstall_freebsd() {
#}

# Usage: uninstall_linux
#uninstall_linux() {
#
#  # source req files
#  safe_source "${WORK_INCLUDES_DIR}/dotfiles.inc"
#  safe_source "${WORK_INCLUDES_DIR}/asdf.inc"
#  safe_source "${WORK_INCLUDES_DIR}/homebrew.inc"
#}

# Usage: uninstall_macos
uninstall_macos() {
  # source req files
  safe_source "${WORK_INCLUDES_DIR}/asdf.inc"
  safe_source "${WORK_INCLUDES_DIR}/homebrew.inc"
  safe_source "${WORK_INCLUDES_DIR}/chezmoi.inc"
  safe_source "${WORK_INCLUDES_DIR}/dotfiles.inc"

  if has_command chezmoi \
    && print_prompt "Would you like to remove chezmoi" "y"; then

    uninstall_chezmoi
  elif [ -d "${XDG_CONFIG_HOME}/shell" ] \
    && print_prompt "Would you like to remove dotfiles" "y"; then

    uninstall_dotfiles
  fi

  if has_command asdf \
    && print_prompt "Would you like to uninstall asdf"; then

    uninstall_asdf
  fi

  if has_command brew || [ -d "$(get_homebrew_prefix)" ] \
    && print_prompt "Would you like to uninstall Homebrew" "y"; then

    uninstall_homebrew
  fi

  # TBD: remove XDG folders?
#  if [ -d "${XDG_CONFIG_HOME}" ] \
#    && print_prompt "Would you like to remove XDG directories" "y"; then
#
#    remove_xdg_base_dirs
#  fi
}

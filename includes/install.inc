# shellcheck shell=sh

check_if_sourced

# Usage: install_freebsd
#install_freebsd() {
#}

# Usage: install_linux
#install_linux() {
#  # source req files
#  safe_source "${WORK_INCLUDES_DIR}/asdf.inc"
#  safe_source "${WORK_INCLUDES_DIR}/nix.inc"
#  safe_source "${WORK_INCLUDES_DIR}/chezmoi.inc"
#  safe_source "${WORK_INCLUDES_DIR}/dotfiles.inc"
#  safe_source "${WORK_INCLUDES_DIR}/nerdfonts.inc"
#  safe_source "${WORK_INCLUDES_DIR}/powerlevel10k.inc"
#  safe_source "${WORK_INCLUDES_DIR}/startship.inc"
#
#  if [ ! -d "${XDG_CONFIG_HOME}" ] \
#    && print_prompt "Would you like to create XDG directories" "y"; then
#
#    create_xdg_base_dirs
#  fi
#
#  if ! has_command asdf \
#    && print_prompt "Would you like to install asdf"; then
#
#    install_asdf
#  fi
#
#  if ! has_command nix \
#    && print_prompt "Would you like to install Nix" "y"; then
#
#    install_nix
#  fi
#
#  if ! has_command chezmoi \
#    && print_prompt "Would you like to get chezmoi" "y"; then
#
#    install_chezmoi
#  elif [ ! -d "${XDG_CONFIG_HOME}/shell" ] \
#    && print_prompt "Would you like to get dotfiles" "y"; then
#
#    install_dotfiles
#  fi
#
#  if [ -d "${XDG_CONFIG_HOME}/nerd-fonts" ] \
#    && print_prompt "Do you want to install Nerd Font(s)" "y"; then
#
#    install_nerdfonts
#  fi
#
#  if [ -d "${XDG_CONFIG_HOME}/powerlevel10k" ] \
#    && print_prompt "Do you want to install Powerlevel10k" "y"; then
#
#    install_powerlevel10k
#  fi
#
#  if [ -d "${XDG_CONFIG_HOME}/starship" ] \
#    && print_prompt "Do you want to install Powerlevel10k" "y"; then
#
#    install_starship
#  fi
#}

# Usage: install_macos
install_macos() {
  # source req files
  safe_source "${WORK_INCLUDES_DIR}/homebrew.inc"
  safe_source "${WORK_INCLUDES_DIR}/chezmoi.inc"
  safe_source "${WORK_INCLUDES_DIR}/dotfiles.inc"

  if [ ! -d "${XDG_CONFIG_HOME}" ] \
    && print_prompt "Would you like to create XDG directories" "y"; then

    create_xdg_base_dirs
  fi

  if ! has_command asdf \
    && print_prompt "Would you like to install asdf"; then

    install_asdf
  fi

  if ! has_command brew \
    && print_prompt "Would you like to install Homebrew" "y"; then

    install_homebrew
  fi

  if ! has_command chezmoi \
    && print_prompt "Would you like to get chezmoi" "y"; then

    install_chezmoi
  elif [ ! -d "${XDG_CONFIG_HOME}/shell" ] \
    && print_prompt "Would you like to get dotfiles" "y"; then

    install_dotfiles
  fi
}

# shellcheck shell=sh

# TODO: will just error if base.inc was not sourced before
check_if_sourced

if [ -n "${XDG_DATA_HOME}" ]; then
  ASDF_CONFIG_FILE="${ASDF_CONFIG_FILE:-"${XDG_CONFIG_HOME}/asdf/asdfrc"}"
  ASDF_DIR="${ASDF_DIR:-"${XDG_DATA_HOME}/asdf"}"
else
  ASDF_CONFIG_FILE="${ASDF_CONFIG_FILE:-"${HOME}/.asdfrc"}"
  ASDF_DIR="${ASDF_DIR:-"${HOME}/.asdf"}"
fi

ASDF_PLUGINS="${ASDF_PLUGINS:-""}"

# provide env vars to subsequent (child) commands
export ASDF_DIR="${ASDF_DIR}"
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-${ASDF_DIR}}"

# Usage: install_asdf
# Description: installs asdf and plugins to <ASDF_DIR>
install_asdf() {
  # check if asdf already exists
  if [ -d "${ASDF_DIR}" ]; then
    print_info "asdf is already installed, skipping"
    return 0
  fi

  # check for asdf deps
  if ! has_command git; then
    print_error "git is required and not found in: ${BOLD}${PATH}${NO_COLOR}"
    return 1
  fi

  print_info "Installing asdf"
  git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" \
    && cd "${ASDF_DIR}" \
    && git switch -c "$(git describe --abbrev=0 --tags)" \
    && cd - > /dev/null

  if [ -d "${ASDF_DIR}" ]; then
    print_success "asdf installed at: ${ASDF_DIR}"

    ! has_command asdf && safe_source "${ASDF_DIR}/asdf.sh"

    # install the list of plugins
    for _plugin in $ASDF_PLUGINS; do
      print_info "Installing ${_plugin} plugin"

      if asdf plugin add $_plugin && asdf install $_plugin latest; then
        print_success "${_plugin} plugin installed"
      else
        print_error "${_plugin} plugin not installed"
      fi
    done
  else
    print_error "asdf was not installed correctly"
    return 1
  fi
}

# Usage: uninstall_asdf
# Description: uninstalls asdf
# Description: uninstalls asdf and plugins from <ASDF_DIR>
uninstall_asdf() {
  # check if asdf already exists
  if [ ! -d "${ASDF_DIR}" ]; then
    print_info "asdf could not be found: ${ASDF_DIR}"
    return 0
  fi

  print_info "Uninstalling asdf"
  if rm -rf "${ASDF_DIR}"; then
    print_success "asdf uninstalled from: ${ASDF_DIR}"
    return 0
  fi

  print_error "Failed to uninstall asdf from: ${ASDF_DIR}"
  return 1

  return 0
}

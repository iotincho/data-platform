#!/usr/bin/env bash

set -o pipefail

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || printf '0')" -ge 8 ]]; then
  COLOR_GREEN="$(tput setaf 2)"
  COLOR_YELLOW="$(tput setaf 3)"
  COLOR_RED="$(tput setaf 1)"
  COLOR_RESET="$(tput sgr0)"
else
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_RESET=""
fi

platform_statuses=()
development_statuses=()
manual_actions=()
hooks_status=""

section() {
  printf '\n%s\n' "$1"
}

success() {
  printf '%s✔ %s%s\n' "$COLOR_GREEN" "$1" "$COLOR_RESET"
}

warning() {
  printf '%s⚠ %s%s\n' "$COLOR_YELLOW" "$1" "$COLOR_RESET"
}

error() {
  printf '%s✖ %s%s\n' "$COLOR_RED" "$1" "$COLOR_RESET" >&2
}

is_available() {
  command -v "$1" >/dev/null 2>&1
}

add_manual_action() {
  manual_actions+=("$1")
}

add_status() {
  local group="$1"
  local state="$2"
  local label="$3"

  if [[ "$group" == "platform" ]]; then
    platform_statuses+=("${state}:${label}")
  else
    development_statuses+=("${state}:${label}")
  fi
}

check_platform_tool() {
  local tool="$1"

  if is_available "$tool"; then
    success "$tool"
    add_status "platform" "ok" "$tool"
  else
    warning "$tool is missing; install it manually."
    add_status "platform" "missing" "$tool missing"
    add_manual_action "Install $tool manually."
  fi
}

add_python_user_bin_to_path() {
  local user_base
  local user_bin

  if ! is_available python3; then
    return
  fi

  user_base="$(python3 -m site --user-base 2>/dev/null)" || return
  user_bin="${user_base}/bin"

  if [[ -d "$user_bin" && ":${PATH}:" != *":${user_bin}:"* ]]; then
    export PATH="${user_bin}:${PATH}"
  fi
}

install_pip_tool() {
  local command_name="$1"
  local package_name="$2"
  local label="$3"

  if is_available "$command_name"; then
    success "$label"
    add_status "development" "ok" "$label"
    return
  fi

  if ! is_available pip3; then
    warning "$label is missing and pip3 is unavailable."
    add_status "development" "missing" "$label not installed"
    add_manual_action "Install $label manually after installing pip3."
    return
  fi

  printf 'Installing %s...\n' "$label"
  if pip3 install --user "$package_name"; then
    add_python_user_bin_to_path
    if is_available "$command_name"; then
      success "$label"
      add_status "development" "ok" "$label"
    else
      warning "$label was installed but is not available on PATH."
      add_status "development" "missing" "$label not available on PATH"
      add_manual_action "Add the Python user bin directory to PATH, then verify $label."
    fi
  else
    error "Could not install $label with pip3."
    add_status "development" "missing" "$label not installed"
    add_manual_action "Install $label manually."
  fi
}

install_tflint() {
  if is_available tflint; then
    success "tflint"
    add_status "development" "ok" "tflint"
    return
  fi

  if ! is_available curl; then
    warning "tflint is missing and curl is unavailable."
    add_status "development" "missing" "tflint not installed"
    add_manual_action "Install tflint manually."
    return
  fi

  if [[ "$(uname -s)" != "Linux" ]]; then
    warning "tflint is missing; the official installer used by this script supports Linux only."
    add_status "development" "missing" "tflint not installed"
    add_manual_action "Install tflint manually for your operating system."
    return
  fi

  printf 'Installing tflint...\n'
  if curl -fsSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; then
    if is_available tflint; then
      success "tflint"
      add_status "development" "ok" "tflint"
    else
      warning "tflint installer completed but tflint is not available on PATH."
      add_status "development" "missing" "tflint not available on PATH"
      add_manual_action "Add the tflint installation directory to PATH, then verify tflint."
    fi
  else
    error "Could not install tflint with the official installer."
    add_status "development" "missing" "tflint not installed"
    add_manual_action "Install tflint manually."
  fi
}

install_markdownlint() {
  if is_available markdownlint; then
    success "markdownlint-cli"
    add_status "development" "ok" "markdownlint-cli"
    return
  fi

  if ! is_available npm; then
    warning "markdownlint-cli is missing and npm is unavailable."
    add_status "development" "missing" "markdownlint-cli not installed"
    add_manual_action "Install markdownlint-cli manually after installing npm."
    return
  fi

  printf 'Installing markdownlint-cli...\n'
  if npm install --global markdownlint-cli; then
    if is_available markdownlint; then
      success "markdownlint-cli"
      add_status "development" "ok" "markdownlint-cli"
    else
      warning "markdownlint-cli was installed but markdownlint is not available on PATH."
      add_status "development" "missing" "markdownlint-cli not available on PATH"
      add_manual_action "Add the npm global bin directory to PATH, then verify markdownlint-cli."
    fi
  else
    error "Could not install markdownlint-cli with npm."
    add_status "development" "missing" "markdownlint-cli not installed"
    add_manual_action "Install markdownlint-cli manually."
  fi
}

install_git_hooks() {
  section "Installing Git hooks..."

  if ! is_available pre-commit; then
    warning "Git hooks were not installed because pre-commit is unavailable."
    hooks_status="missing:pre-commit hooks not installed"
    add_manual_action "Run pre-commit install after pre-commit is available."
    return
  fi

  if pre-commit install; then
    success "pre-commit hooks installed"
    hooks_status="ok:pre-commit installed"
  else
    error "Could not install pre-commit hooks."
    hooks_status="missing:pre-commit hooks not installed"
    add_manual_action "Run pre-commit install manually."
  fi
}

print_statuses() {
  local title="$1"
  shift
  local status
  local state
  local label

  printf '\n%s\n' "$title"
  for status in "$@"; do
    state="${status%%:*}"
    label="${status#*:}"
    if [[ "$state" == "ok" ]]; then
      success "$label"
    else
      warning "$label"
    fi
  done
}

print_summary() {
  section "Done."
  print_statuses "Platform tools" "${platform_statuses[@]}"
  print_statuses "Development tools" "${development_statuses[@]}"
  print_statuses "Git Hooks" "$hooks_status"

  if ((${#manual_actions[@]} > 0)); then
    printf '\n%sManual actions remaining:%s\n' "$COLOR_YELLOW" "$COLOR_RESET"
    local action
    for action in "${manual_actions[@]}"; do
      printf '%s- %s%s\n' "$COLOR_YELLOW" "$action" "$COLOR_RESET"
    done
  fi
}

main() {
  section "Checking platform requirements..."
  check_platform_tool terraform
  check_platform_tool aws
  check_platform_tool git
  check_platform_tool python3

  section "Installing development tools..."
  add_python_user_bin_to_path
  install_pip_tool pre-commit pre-commit pre-commit
  install_tflint
  install_pip_tool yamllint yamllint yamllint
  install_markdownlint

  install_git_hooks
  print_summary
}

main "$@"

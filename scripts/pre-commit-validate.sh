#!/usr/bin/env bash

set -o pipefail
export AWS_DEFAULT_REGION=us-east-1

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
documentation_failures=0
documentation_warnings=()

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

require_tool() {
  local tool="$1"

  if is_available "$tool"; then
    return 0
  fi

  error "$tool is required for repository validation."
  return 1
}

discover_root_modules() {
  find live -type d -name .terraform -prune -o -type f -name main.tf -exec dirname {} \; | sort
}

validate_formatting() {
  section "Terraform formatting"

  if terraform fmt -check -recursive; then
    success "terraform fmt"
  else
    error "terraform fmt failed."
    return 1
  fi
}

validate_root_module() {
  local root_module="$1"

  section "Checking ${root_module}"

  if terraform -chdir="$root_module" init -backend=false -input=false -upgrade=false; then
    success "terraform init"
  else
    error "terraform init failed in ${root_module}."
    return 1
  fi

  if terraform -chdir="$root_module" validate; then
    success "terraform validate"
  else
    error "terraform validate failed in ${root_module}."
    return 1
  fi

  if (cd "$root_module" && tflint); then
    success "tflint"
  else
    error "tflint failed in ${root_module}."
    return 1
  fi
}

validate_markdown() {
  if ! is_available markdownlint; then
    warning "markdownlint unavailable; skipping Markdown validation."
    documentation_warnings+=("markdownlint unavailable")
    return
  fi

  if markdownlint "**/*.md"; then
    success "Markdown validation"
  else
    error "Markdown validation failed."
    documentation_failures=1
  fi
}

validate_yaml() {
  if ! is_available yamllint; then
    warning "yamllint unavailable; skipping YAML validation."
    documentation_warnings+=("yamllint unavailable")
    return
  fi

  if yamllint .; then
    success "YAML validation"
  else
    error "YAML validation failed."
    documentation_failures=1
  fi
}

validate_documentation() {
  section "Documentation validation"
  validate_markdown
  validate_yaml
}

print_success_summary() {
  section "Summary"
  printf '\nTerraform\n'
  success "Passed"

  printf '\nDocumentation\n'
  if ((${#documentation_warnings[@]} == 0)); then
    success "Passed"
  else
    local warning_message
    for warning_message in "${documentation_warnings[@]}"; do
      warning "$warning_message"
    done
  fi

  printf '\nOverall\n'
  success "Repository validation completed successfully"
}

main() {
  cd "$repository_root" || exit 1

  require_tool terraform || exit 1
  require_tool tflint || exit 1

  local root_modules=()
  mapfile -t root_modules < <(discover_root_modules)

  if ((${#root_modules[@]} == 0)); then
    error "No Terraform Root Modules were found under live/."
    exit 1
  fi

  validate_formatting || exit 1

#  local root_module
#  for root_module in "${root_modules[@]}"; do
#    validate_root_module "$root_module" || exit 1
#  done

#  validate_documentation

#  if ((documentation_failures)); then
#    section "Summary"
#    error "Documentation validation failed."
#    exit 1
#  fi

# print_success_summary
}

main "$@"

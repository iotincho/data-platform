#!/usr/bin/env bash

set -euo pipefail

################################################################################
# Colors
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m'

################################################################################
# Logging
################################################################################

section() {
    echo
    echo -e "${BLUE}==> $1${NC}"
}

success() {
    echo -e "${GREEN}✔ $1${NC}"
}

error() {
    echo -e "${RED}✖ $1${NC}"
}

################################################################################
# Validation
################################################################################

validate_root_module() {
    local root_module="$1"

    section "Checking ${root_module}"

    terraform -chdir="${root_module}" init \
        -backend=false \
        -input=false

    success "terraform init"

    terraform -chdir="${root_module}" validate

    success "terraform validate"

    (
        cd "${root_module}"

        tflint --init >/dev/null 2>&1 || true
        tflint
    )

    success "tflint"
}

################################################################################
# Main
################################################################################

section "Terraform formatting"

terraform fmt -check -recursive

success "terraform fmt"

section "Discovering Root Modules"

mapfile -t ROOT_MODULES < <(
    find live \
        -type f \
        -name main.tf \
        -exec dirname {} \; \
        | sort
)

if [[ ${#ROOT_MODULES[@]} -eq 0 ]]; then
    error "No Terraform Root Modules found."
    exit 1
fi

for module in "${ROOT_MODULES[@]}"; do
    validate_root_module "${module}"
done

echo
section "Summary"

success "Terraform validation completed successfully."
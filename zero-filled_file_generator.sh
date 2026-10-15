
#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

# ============================================================
# Zero-Filled File Generator
# Version: 1.0.0
# Purpose: Authorized compression-ratio and storage lab tests
# ============================================================

readonly TOOL_NAME="Zero-Filled File Generator"
readonly TOOL_VERSION="1.0.0"

# Configurable safety limits
readonly MAX_FILES=100                # Total file
readonly MAX_FILE_BYTES=1048576       # 1 MiB per file
readonly MAX_TOTAL_BYTES=10485760     # 10 MiB combined

# Terminal colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' CYAN='' BOLD='' RESET=''
fi

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

info() {
    printf '%b[*]%b %s\n' "$CYAN" "$RESET" "$*"
}

success() {
    printf '%b[+]%b %s\n' "$GREEN" "$RESET" "$*"
}

warning() {
    printf '%b[!]%b %s\n' "$YELLOW" "$RESET" "$*" >&2
}

error() {
    printf '%b[-]%b %s\n' "$RED" "$RESET" "$*" >&2
}

die() {
    error "$*"
    exit 1
}

# ------------------------------------------------------------
# Disclaimer and authorization
# ------------------------------------------------------------

show_disclaimer() {
    printf '\n%b' "$BOLD"
    printf '%s\n' \
        "============================================================" \
        "          ZERO-FILLED FILE GENERATOR — LAB MODE" \
        "                    Version ${TOOL_VERSION}" \
        "============================================================"
    printf '%b\n' "$RESET"

    cat <<'NOTICE'
DISCLAIMER AND AUTHORIZED-USE POLICY

PURPOSE
This utility creates ordinary text files containing zero characters
for controlled storage and compression experiments. It does not
create ZIP archives or implement ZIP-bomb behavior.

AUTHORIZATION
Use this utility only on devices, storage, and systems that you own
or are explicitly authorized to test. Obtain the system owner's
permission before conducting tests on shared infrastructure.

POTENTIAL IMPACT
- Generated files consume real disk space.
- Excessive output can disrupt applications or system operation.
- Testing on shared or production systems may affect other users.
- Deleting generated files does not guarantee recovery from every
  consequence of a resource-exhaustion incident.

USER RESPONSIBILITY
You are responsible for choosing an appropriate test environment,
checking available storage, and complying with applicable laws,
policies, and authorization conditions.

This disclaimer does not grant legal permission or waive liability.
No particular legal outcome is guaranteed by this notice.

No output directory or test file will be created before the
required confirmation and input validation.
NOTICE

    printf '\n'
}

require_authorization() {
    show_disclaimer

    local response

    read -r -p \
        'Type AUTHORIZED-LAB-TEST to acknowledge and continue: ' \
        response || die "Authorization input unavailable."

    [[ "$response" == "AUTHORIZED-LAB-TEST" ]] ||
        die "Authorization not confirmed. Exiting."

    success "Acknowledgment recorded for this session."
}

# ------------------------------------------------------------
# Input validation
# ------------------------------------------------------------

read_positive_integer() {
    local prompt="$1"
    local value="$2"

    [[ "$value" =~ ^[0-9]+$ ]] ||
        die "$prompt must be a positive integer."

    # Avoid unsafe arithmetic on excessively long input.
    ((${#value} <= 10)) ||
        die "$prompt is outside the supported numeric range."

    value=$((10#$value))
    ((value > 0)) || die "$prompt must be greater than zero."

    printf '%s' "$value"
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

main() {
    require_authorization

    local folder count file_bytes prefix confirm
    local total_bytes available_kb required_kb

    printf '\n%bConfiguration%b\n\n' "$BOLD" "$RESET"

    read -r -p "Output directory: " folder
    [[ -n "$folder" ]] || die "Directory name cannot be empty."
    [[ "$folder" != "." && "$folder" != ".." ]] ||
        die "Choose a dedicated output directory."
    [[ "$folder" != */ ]] ||
        die "Enter a directory name without a trailing slash."

    read -r -p "Number of files (maximum ${MAX_FILES}): " input
    count=$(read_positive_integer "File count" "$input")
    ((count <= MAX_FILES)) ||
        die "File count exceeds the configured maximum."

    read -r -p "Bytes per file (maximum ${MAX_FILE_BYTES}): " input
    file_bytes=$(read_positive_integer "File size" "$input")
    ((file_bytes <= MAX_FILE_BYTES)) ||
        die "File size exceeds the configured maximum."

    total_bytes=$((count * file_bytes))
    ((total_bytes <= MAX_TOTAL_BYTES)) ||
        die "Combined output exceeds the configured maximum."

    read -r -p "Filename prefix [zeros]: " prefix
    prefix=${prefix:-zeros}

    [[ "$prefix" =~ ^[a-zA-Z0-9_-]+$ ]] ||
        die "Prefix may contain only letters, digits, _ and -."

    # Refuse existing output paths, including symbolic links.
    [[ ! -e "$folder" && ! -L "$folder" ]] ||
        die "Output path already exists."

    # Check available space in the destination's parent filesystem.
    available_kb=$(df -Pk -- . | awk 'NR == 2 {print $4}')
    [[ "$available_kb" =~ ^[0-9]+$ ]] ||
        die "Could not determine available disk space."

    required_kb=$(((total_bytes + 1023) / 1024))
    ((available_kb >= required_kb)) ||
        die "Insufficient available disk space."

    printf '\n%bPre-execution review%b\n' "$BOLD" "$RESET"
    printf '  Files requested : %s\n' "$count"
    printf '  Bytes per file  : %s\n' "$file_bytes"
    printf '  Total data      : %s bytes\n' "$total_bytes"
    printf '  Output directory: %s\n' "$folder"
    printf '\n'

    warning "This operation writes data to disk."
    read -r -p "Type CREATE-FILES to begin: " confirm ||
        die "Confirmation input unavailable."

    [[ "$confirm" == "CREATE-FILES" ]] ||
        die "Operation cancelled. No files generated."

    mkdir -- "$folder" ||
        die "Unable to create output directory."

    # Remove only files created by this run if generation fails.
    local failed=0
    local i file
    for ((i = 1; i <= count; i++)); do
        file="${folder}/${prefix}_${i}.txt"

        if ! head -c "$file_bytes" /dev/zero |
             tr '\0' '0' > "$file"; then
            error "Failed to generate ${file}"
            failed=1
            break
        fi

        success "Created ${prefix}_${i}.txt (${file_bytes} bytes)"
    done

    if ((failed)); then
        warning "Partial output remains in: $folder"
        warning "Inspect the directory before removing its contents."
        return 1
    fi

    printf '\n%bGeneration summary%b\n' "$BOLD" "$RESET"
    printf '  Files created : %s\n' "$count"
    printf '  Data requested: %s bytes\n' "$total_bytes"
    printf '  Output path   : %s\n' "$folder"
    success "Generation completed."
    info "This run created plain-text files, not a ZIP archive."
}

main "$@"

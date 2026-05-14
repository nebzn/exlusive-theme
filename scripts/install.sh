#!/usr/bin/env bash
# ============================================================
#  Exclusive Theme installer
#  https://github.com/nebzn/exclusive-theme
# ============================================================
#
# Variants:
#   ExclusiveBone      - bone-white text (luminous, recommended)
#   ExclusiveAsh       - light ash-grey text
#   ExclusiveTea       - mid ash-grey text
#   ExclusiveSand      - deep sandy beige text
#   ExclusiveMidnight  - warm cream text
#
# Usage:
#   ./install.sh                     interactive installer
#   ./install.sh install             interactive variant chooser
#   ./install.sh install <variant>   install a specific variant by name
#   ./install.sh install-all         install every variant
#   ./install.sh uninstall           remove every installed Exclusive theme
#   ./install.sh --help
# ============================================================

set -e

# ---------- installer output colors ----------
PURPLE='\033[38;5;141m'
PURPLE_BOLD='\033[1;38;5;141m'
GREEN='\033[38;5;120m'
RED='\033[38;5;203m'
CERULEAN='\033[38;5;110m'
BEIGE='\033[38;5;180m'
BONE='\033[38;5;230m'
DIM='\033[2m'
RESET='\033[0m'

# ---------- paths ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
QTERMINAL_THEMES_DIR="$REPO_ROOT/themes/qterminal"
GNOME_THEMES_DIR="$REPO_ROOT/themes/gnome-terminal"

VARIANTS=("ExclusiveBone" "ExclusiveAsh" "ExclusiveTea" "ExclusiveSand" "ExclusiveMidnight")
DEFAULT_VARIANT="ExclusiveBone"

# ---------- detect qtermwidget version ----------
detect_qtermwidget_version() {
    if [[ -d /usr/share/qtermwidget6/color-schemes ]]; then
        echo 6
    elif [[ -d /usr/share/qtermwidget5/color-schemes ]]; then
        echo 5
    else
        echo ""
    fi
}
QTERM_VERSION="$(detect_qtermwidget_version)"

# ---------- helpers ----------
banner() {
    echo
    echo -e "${PURPLE_BOLD}╭─────────────────────────────────────────────╮${RESET}"
    echo -e "${PURPLE_BOLD}│${RESET}  ${BONE}Exclusive — terminal theme installer${RESET}     ${PURPLE_BOLD}│${RESET}"
    echo -e "${PURPLE_BOLD}╰─────────────────────────────────────────────╯${RESET}"
    echo
}

step()    { echo -e "${PURPLE}┌──${RESET} ${BONE}$1${RESET}"; }
ok()      { echo -e "  ${GREEN}✓${RESET} $1"; }
warn()    { echo -e "  ${BEIGE}!${RESET} $1"; }
err()     { echo -e "  ${RED}✗${RESET} $1"; }
info()    { echo -e "  ${CERULEAN}i${RESET} ${DIM}$1${RESET}"; }

ask_yn() {
    local prompt="$1"
    local default="${2:-n}"
    local hint
    if [[ "$default" == "y" ]]; then
        hint="${PURPLE_BOLD}Y${RESET}/${DIM}n${RESET}"
    else
        hint="${DIM}y${RESET}/${PURPLE_BOLD}N${RESET}"
    fi
    local reply
    echo -ne "  ${CERULEAN}?${RESET} $prompt [${hint}]: "
    read -r reply </dev/tty
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy] ]]
}

require_root_for() {
    if [[ $EUID -ne 0 ]]; then
        echo "sudo"
    fi
}

variant_exists() {
    local v="$1"
    for known in "${VARIANTS[@]}"; do
        [[ "$known" == "$v" ]] && return 0
    done
    return 1
}

# ---------- install single qterminal variant ----------
install_qterminal_variant() {
    local variant="$1"
    local source_file="$QTERMINAL_THEMES_DIR/${variant}.colorscheme"

    if [[ ! -f "$source_file" ]]; then
        err "Theme file not found: $source_file"
        return 1
    fi

    if [[ -z "$QTERM_VERSION" ]]; then
        warn "qterminal not detected. Installing to user color-schemes directory."
        local user_dir="$HOME/.local/share/qtermwidget6/color-schemes"
        mkdir -p "$user_dir"
        cp "$source_file" "$user_dir/"
        ok "Installed: $user_dir/${variant}.colorscheme"
    else
        local target_dir="/usr/share/qtermwidget${QTERM_VERSION}/color-schemes"
        $(require_root_for) cp "$source_file" "$target_dir/"
        ok "Installed: $target_dir/${variant}.colorscheme"
    fi
}

# ---------- install gnome-terminal profile ----------
install_gnome_terminal_variant() {
    local variant="$1"
    local source_file="$GNOME_THEMES_DIR/${variant}.dconf"

    if [[ ! -f "$source_file" ]]; then
        err "gnome-terminal file not found: $source_file"
        return 1
    fi
    if ! command -v dconf &>/dev/null || ! command -v gnome-terminal &>/dev/null; then
        warn "gnome-terminal or dconf not available; skipping."
        return 0
    fi

    local new_uuid
    new_uuid="$(uuidgen 2>/dev/null || python3 -c 'import uuid;print(uuid.uuid4())')"
    local base_path="/org/gnome/terminal/legacy/profiles:"
    local current_list
    current_list="$(dconf read "${base_path}/list" 2>/dev/null || echo "[]")"

    local new_list
    if [[ "$current_list" == "[]" || -z "$current_list" ]]; then
        new_list="['$new_uuid']"
    else
        new_list="${current_list%]}, '$new_uuid']"
    fi

    dconf write "${base_path}/list" "$new_list"
    dconf load "${base_path}/:${new_uuid}/" < "$source_file"
    ok "gnome-terminal profile '${variant}' added (UUID: ${new_uuid:0:8}…)"
}

# ---------- Cascadia Code font ----------
install_cascadia_font() {
    step "Cascadia Code font"

    if fc-list 2>/dev/null | grep -qi "cascadia"; then
        ok "Cascadia Code is already installed."
        return 0
    fi

    if ! command -v apt &>/dev/null; then
        warn "apt not available; cannot auto-install fonts on this system."
        info "Install Cascadia Code manually: https://github.com/microsoft/cascadia-code"
        return 0
    fi

    if ask_yn "Install Cascadia Code now (sudo apt install fonts-cascadia-code)?" "y"; then
        info "Installing fonts-cascadia-code..."
        sudo apt update -qq
        sudo apt install -y fonts-cascadia-code
        fc-cache -f >/dev/null 2>&1 || true
        ok "Cascadia Code installed."
        info "Open Preferences → Appearance → Font → 'Cascadia Code'."
    else
        info "Skipped font installation."
    fi
}

# ---------- uninstall ----------
uninstall_all() {
    banner
    step "Removing Exclusive themes"

    if [[ -n "$QTERM_VERSION" ]]; then
        local target_dir="/usr/share/qtermwidget${QTERM_VERSION}/color-schemes"
        for v in "${VARIANTS[@]}"; do
            local f="$target_dir/${v}.colorscheme"
            if [[ -f "$f" ]]; then
                $(require_root_for) rm -f "$f"
                ok "Removed: $f"
            fi
        done
    fi

    local user_dir="$HOME/.local/share/qtermwidget6/color-schemes"
    if [[ -d "$user_dir" ]]; then
        for v in "${VARIANTS[@]}"; do
            local f="$user_dir/${v}.colorscheme"
            if [[ -f "$f" ]]; then
                rm -f "$f"
                ok "Removed: $f"
            fi
        done
    fi

    info "gnome-terminal profiles are NOT removed automatically (UUIDs vary)."
    info "Delete them from gnome-terminal Preferences if you no longer want them."
    echo
    ok "Done."
}

# ---------- variant chooser ----------
choose_variant() {
    echo -e "  ${BONE}Choose a variant:${RESET}"
    echo
    echo -e "  ${PURPLE_BOLD}1)${RESET} ${BONE}ExclusiveBone${RESET}      ${DIM}bone-white text · luminous · recommended${RESET}"
    echo -e "  ${PURPLE_BOLD}2)${RESET} ExclusiveAsh        ${DIM}light ash-grey text · balanced${RESET}"
    echo -e "  ${PURPLE_BOLD}3)${RESET} ExclusiveTea        ${DIM}mid ash-grey text · sober${RESET}"
    echo -e "  ${PURPLE_BOLD}4)${RESET} ExclusiveSand       ${DIM}deep sandy beige · warm${RESET}"
    echo -e "  ${PURPLE_BOLD}5)${RESET} ExclusiveMidnight   ${DIM}warm cream · vintage${RESET}"
    echo -e "  ${PURPLE_BOLD}6)${RESET} Install all five"
    echo
    echo -ne "  ${CERULEAN}?${RESET} Choice [1-6, default 1]: "
    local choice
    read -r choice </dev/tty
    choice="${choice:-1}"
    case "$choice" in
        1) SELECTED_VARIANTS=("ExclusiveBone") ;;
        2) SELECTED_VARIANTS=("ExclusiveAsh") ;;
        3) SELECTED_VARIANTS=("ExclusiveTea") ;;
        4) SELECTED_VARIANTS=("ExclusiveSand") ;;
        5) SELECTED_VARIANTS=("ExclusiveMidnight") ;;
        6) SELECTED_VARIANTS=("${VARIANTS[@]}") ;;
        *) err "Invalid choice."; exit 1 ;;
    esac
}

# ---------- install routine ----------
do_install_selected() {
    banner
    step "Detecting environment"
    if [[ -n "$QTERM_VERSION" ]]; then
        ok "Found qtermwidget${QTERM_VERSION}"
    else
        warn "qterminal not detected."
    fi
    if command -v gnome-terminal &>/dev/null; then
        ok "Found gnome-terminal"
    fi
    echo

    step "Installing: ${SELECTED_VARIANTS[*]}"
    for v in "${SELECTED_VARIANTS[@]}"; do
        install_qterminal_variant "$v"
    done

    if command -v gnome-terminal &>/dev/null; then
        echo
        if ask_yn "Also add these as gnome-terminal profiles?" "n"; then
            for v in "${SELECTED_VARIANTS[@]}"; do
                install_gnome_terminal_variant "$v"
            done
        fi
    fi

    echo
    install_cascadia_font

    echo
    final_instructions "${SELECTED_VARIANTS[0]}"
}

# Plain-text final instructions (no ANSI codes) to ensure consistent output
# across shells / heredoc quirks. The body is intentionally simple.
final_instructions() {
    local variant="${1:-ExclusiveBone}"
    echo
    echo "Done!"
    echo
    echo "Next steps:"
    echo "  1. Close qterminal completely and reopen it."
    echo "  2. Preferences -> Appearance -> Color scheme -> ${variant}"
    echo "  3. Same panel -> Font -> Change -> Cascadia Code (size 11 or 12)."
    echo "  4. Click Apply -> OK."
    echo
    echo "Enjoy your new terminal!"
    echo
}

usage() {
    cat <<'EOF'

Usage: ./install.sh [command] [variant]

Commands:
  install                       Interactive variant chooser + font prompt
  install <variant>             Install a specific variant by name
  install-all                   Install every variant
  uninstall                     Remove every installed Exclusive theme
  --help, -h                    Show this message

Variants:
  ExclusiveBone (default, recommended)
  ExclusiveAsh
  ExclusiveTea
  ExclusiveSand
  ExclusiveMidnight

With no command, an interactive menu is shown.

EOF
}

interactive_menu() {
    banner
    choose_variant
    do_install_selected
}

# ---------- main ----------
main() {
    case "${1:-}" in
        ""|menu)
            interactive_menu
            ;;
        install)
            if [[ -n "${2:-}" ]]; then
                if variant_exists "$2"; then
                    SELECTED_VARIANTS=("$2")
                    do_install_selected
                else
                    err "Unknown variant: $2"
                    info "Available: ${VARIANTS[*]}"
                    exit 1
                fi
            else
                interactive_menu
            fi
            ;;
        install-all)
            SELECTED_VARIANTS=("${VARIANTS[@]}")
            do_install_selected
            ;;
        uninstall)
            uninstall_all
            ;;
        -h|--help)
            usage
            ;;
        *)
            err "Unknown command: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"

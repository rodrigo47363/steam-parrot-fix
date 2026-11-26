#!/usr/bin/env bash
# =============================================================================
# fix-steam-parrot.sh
# Script de solución automática para Steam en Parrot OS
# Repositorio: https://github.com/rodrigo47363/steam-parrot-fix
# Licencia: MIT
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

STEAM_DIR="${HOME}/.local/share/Steam"
MARKER_FILE="${STEAM_DIR}/.steam-enable-steamrt64-client"
STEAMRT64="${STEAM_DIR}/steamrt64/steam"

# ---------------------------------------------------------------------------
print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          Steam Fix for Parrot OS — by rodrigo47363           ║"
    echo "║      Soluciona libs 32-bit y activa el cliente 64-bit        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERR ]${NC}  $*"; }
header()  { echo -e "\n${BOLD}──────────────────────────────────────────${NC}"; echo -e "${BOLD}  $*${NC}"; echo -e "${BOLD}──────────────────────────────────────────${NC}"; }

# ---------------------------------------------------------------------------
detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        OS_NAME="${NAME:-Unknown}"
        OS_VERSION="${VERSION_ID:-Unknown}"
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
    fi
}

check_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        error "No ejecutes este script como root. Se usará pkexec/sudo según sea necesario."
        exit 1
    fi
}

check_dependencies() {
    header "Verificando dependencias del sistema"
    local missing=()
    for cmd in dpkg apt-get; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Comandos no encontrados: ${missing[*]}"
        error "Este script requiere un sistema basado en Debian/Parrot OS."
        exit 1
    fi
    ok "Sistema Debian/Parrot OS detectado: ${OS_NAME} ${OS_VERSION}"
}

check_arch() {
    header "Verificando arquitectura"
    local dpkg_arch
    dpkg_arch="$(dpkg --print-architecture)"
    if [[ "$dpkg_arch" != "amd64" ]]; then
        error "Se requiere arquitectura amd64. Detectada: $dpkg_arch"
        exit 1
    fi

    # Enable i386 if not enabled
    if ! dpkg --print-foreign-architectures | grep -q "i386"; then
        warn "Arquitectura i386 no habilitada. Activando..."
        _elevate dpkg --add-architecture i386
        ok "Arquitectura i386 habilitada."
    else
        ok "Arquitectura i386 ya habilitada."
    fi
}

# Decide between sudo and pkexec
_elevate() {
    if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo "$@"
    elif command -v pkexec &>/dev/null; then
        pkexec "$@"
    else
        error "No se encontró sudo ni pkexec. Instala uno de ellos e intenta de nuevo."
        exit 1
    fi
}

install_32bit_libs() {
    header "Instalando bibliotecas 32-bit requeridas"
    info "Actualizando índice de paquetes..."
    _elevate apt-get update -qq

    local pkgs=(libc6:i386 libgcc-s1:i386)
    local optional_pkgs=(libgl1:i386 libegl1:i386 libgbm1:i386)

    info "Instalando paquetes obligatorios: ${pkgs[*]}"
    _elevate apt-get install -y "${pkgs[@]}" || {
        error "Error al instalar las librerías obligatorias."
        error "Revisa los conflictos de repositorios con: apt-get install -y ${pkgs[*]}"
        exit 1
    }
    ok "Librerías 32-bit básicas instaladas correctamente."

    # Try optional gfx libs but don't fail on conflict
    if _elevate apt-get install -y "${optional_pkgs[@]}" 2>/dev/null; then
        ok "Librerías gráficas 32-bit instaladas."
    else
        warn "No se pudieron instalar las libs gráficas 32-bit (conflicto de repos). Se usará el runtime de SteamRT64 (es normal)."
    fi
}

check_steam_installed() {
    header "Verificando instalación de Steam"
    if ! command -v steam &>/dev/null; then
        error "Steam no está instalado. Instálalo con:"
        error "  sudo apt-get install steam"
        exit 1
    fi
    ok "Steam encontrado: $(command -v steam)"

    if [[ ! -d "${STEAM_DIR}" ]]; then
        warn "Directorio de Steam no encontrado en ${STEAM_DIR}"
        warn "Ejecuta Steam al menos una vez para que se cree el directorio."
        exit 1
    fi
    ok "Directorio de Steam: ${STEAM_DIR}"
}

enable_steamrt64_client() {
    header "Activando cliente nativo 64-bit de Steam"

    if [[ -f "${MARKER_FILE}" ]]; then
        ok "El marcador de cliente 64-bit ya existe: ${MARKER_FILE}"
    else
        touch "${MARKER_FILE}"
        ok "Marcador creado: ${MARKER_FILE}"
    fi

    if [[ -f "${STEAMRT64}" ]]; then
        ok "Cliente SteamRT64 encontrado: ${STEAMRT64}"
    else
        warn "No se encontró el cliente 64-bit en ${STEAMRT64}"
        warn "Ejecuta Steam una vez para que descargue el runtime SteamRT64."
    fi
}

verify_fix() {
    header "Verificación final"
    local all_ok=true

    # Check libs
    if ldconfig -p | grep -q "libc.so.6 (ELF 64bit x86-64)"; then
        ok "libc6 (64-bit) disponible."
    fi
    if dpkg -l "libc6:i386" &>/dev/null; then
        ok "libc6:i386 instalada."
    else
        warn "libc6:i386 no detectada."
        all_ok=false
    fi

    # Check marker
    if [[ -f "${MARKER_FILE}" ]]; then
        ok "Marcador SteamRT64 activo: ${MARKER_FILE}"
    else
        error "Marcador SteamRT64 NO encontrado."
        all_ok=false
    fi

    echo ""
    if [[ "$all_ok" == "true" ]]; then
        echo -e "${GREEN}${BOLD}✔  Todo listo. Ejecuta 'steam' para iniciarlo.${NC}"
    else
        echo -e "${YELLOW}${BOLD}⚠  Algunas verificaciones fallaron. Revisa los WARNs arriba.${NC}"
    fi
}

usage() {
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  --only-libs         Solo instala las librerías 32-bit"
    echo "  --only-64bit        Solo activa el cliente 64-bit de Steam"
    echo "  --verify            Solo verifica el estado del sistema"
    echo "  --help, -h          Muestra esta ayuda"
    echo ""
    echo "Sin opciones: ejecuta el flujo completo."
}

# ---------------------------------------------------------------------------
main() {
    print_banner
    detect_os
    check_root

    local mode="full"
    case "${1:-}" in
        --only-libs)   mode="libs" ;;
        --only-64bit)  mode="64bit" ;;
        --verify)      mode="verify" ;;
        --help|-h)     usage; exit 0 ;;
        "")            mode="full" ;;
        *)             error "Opción desconocida: ${1}"; usage; exit 1 ;;
    esac

    case "$mode" in
        full)
            check_dependencies
            check_arch
            install_32bit_libs
            check_steam_installed
            enable_steamrt64_client
            verify_fix
            ;;
        libs)
            check_dependencies
            check_arch
            install_32bit_libs
            ;;
        64bit)
            check_steam_installed
            enable_steamrt64_client
            ;;
        verify)
            verify_fix
            ;;
    esac
}

main "$@"

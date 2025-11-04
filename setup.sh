#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${ROOT_DIR}/target"

TEXT_BUNDLE="${TARGET_DIR}/sublime-text.flatpak"
MERGE_BUNDLE="${TARGET_DIR}/sublime-merge.flatpak"

TEXT_APPID="com.sublimetext.sublime_text"
MERGE_APPID="com.sublimemerge.sublime_merge"

log()  { printf "\033[1;36m[setup]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[setup]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[setup]\033[0m %s\n" "$*" >&2; }

check_bundle_exists() { [[ -f "$1" ]]; }
is_installed() { flatpak list --app --columns=application | grep -qx "$1"; }

ensure_script() {
  local path="$1" name="$2"
  [[ -x "$path" ]] || err "No se encontró $name ejecutable en: $path"
}

# -------- Construction --------
build_packages_normal() {
  if check_bundle_exists "$TEXT_BUNDLE" && check_bundle_exists "$MERGE_BUNDLE"; then
    log "Los paquetes ya están construidos. Volviendo al menú principal..."
    return
  fi
  ensure_script "${ROOT_DIR}/builder.sh" "builder.sh"
  log "Ejecutando builder.sh (construcción normal)..."
  "${ROOT_DIR}/builder.sh"
}

build_packages_force() {
  ensure_script "${ROOT_DIR}/builder.sh" "builder.sh"
  log "Forzando construcción de todos modos..."
  "${ROOT_DIR}/builder.sh"
}

build_menu() {
  echo "=== Construir paquetes ==="
  echo "1) Construcción normal (respeta bundles existentes)"
  echo "2) Forzar construcción (siempre reconstruye ambos)"
  echo "3) Volver"
  read -rp "Opción: " opt
  case "$opt" in
    1) build_packages_normal ;;
    2) build_packages_force ;;
    *) return ;;
  esac
}

# -------- Installation --------
install_one() {
  local bundle="$1" appid="$2" name="$3"
  if ! check_bundle_exists "$bundle"; then
    warn "No existe el bundle de $name en target/. Construye primero."
    return
  fi
  if is_installed "$appid"; then
    read -rp "$name ya está instalado. ¿Quieres actualizarlo desde el bundle? (s/n): " ans
    if [[ "$ans" =~ ^[sS]$ ]]; then
      flatpak install --user --noninteractive --reinstall "$bundle"
      log "$name actualizado desde el bundle."
    else
      log "Omitiendo actualización de $name."
    fi
  else
    flatpak install --user --noninteractive "$bundle"
    log "$name instalado."
  fi
}

install_packages() {
  echo "=== Instalar paquetes ==="
  echo "1) Sublime Text"
  echo "2) Sublime Merge"
  echo "3) Ambos"
  echo "4) Volver"
  read -rp "Opción: " opt
  case "$opt" in
    1) install_one "$TEXT_BUNDLE" "$TEXT_APPID" "Sublime Text" ;;
    2) install_one "$MERGE_BUNDLE" "$MERGE_APPID" "Sublime Merge" ;;
    3)
      install_one "$TEXT_BUNDLE" "$TEXT_APPID" "Sublime Text"
      install_one "$MERGE_BUNDLE" "$MERGE_APPID" "Sublime Merge"
      ;;
    *) return ;;
  esac
}

# -------- Uninstallation --------
uninstall_one() {
  local appid="$1" name="$2"
  if is_installed "$appid"; then
    read -rp "¿Desinstalar $name? (s/n): " ans
    if [[ "$ans" =~ ^[sS]$ ]]; then
      read -rp "¿Eliminar también los datos de usuario de $name? (s/n): " del
      if [[ "$del" =~ ^[sS]$ ]]; then
        flatpak uninstall --user --delete-data --noninteractive "$appid"
        log "$name desinstalado y datos eliminados."
      else
        flatpak uninstall --user --noninteractive "$appid"
        log "$name desinstalado (datos conservados)."
      fi
    else
      log "Desinstalación de $name cancelada."
    fi
  else
    warn "$name no está instalado."
  fi
}

uninstall_packages() {
  echo "=== Desinstalar paquetes ==="
  echo "1) Sublime Text"
  echo "2) Sublime Merge"
  echo "3) Ambos"
  echo "4) Volver"
  read -rp "Opción: " opt
  case "$opt" in
    1) uninstall_one "$TEXT_APPID" "Sublime Text" ;;
    2) uninstall_one "$MERGE_APPID" "Sublime Merge" ;;
    3)
      uninstall_one "$TEXT_APPID" "Sublime Text"
      uninstall_one "$MERGE_APPID" "Sublime Merge"
      ;;
    *) return ;;
  esac
}

# -------- Cleaning --------
clean_project() {
  ensure_script "${ROOT_DIR}/cleaner.sh" "cleaner.sh"
  log "Ejecutando cleaner.sh..."
  "${ROOT_DIR}/cleaner.sh"
}

# ========= Main menu =========
while true; do
  echo "=== Setup CLI ==="
  echo "1) Construir paquetes"
  echo "2) Instalar paquetes"
  echo "3) Desinstalar paquetes"
  echo "4) Limpiar proyecto"
  echo "5) Salir"
  read -rp "Opción: " choice
  case "$choice" in
    1) build_menu ;;
    2) install_packages ;;
    3) uninstall_packages ;;
    4) clean_project ;;
    5) exit 0 ;;
    *) echo "Opción inválida" ;;
  esac
done

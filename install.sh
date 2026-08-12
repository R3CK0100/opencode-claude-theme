#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_CSS="${SCRIPT_DIR}/claude-desktop-theme.css"
TARGET_DIR="${HOME}/.local/share/OpenCode/resources"
ORIGINAL_ASAR="/opt/OpenCode/resources/app.asar"
TMP_DIR="/tmp/opencode-build"

echo "=== Aplicando Tema Claude Desktop a OpenCode ==="

if [ ! -f "${ORIGINAL_ASAR}" ]; then
    echo "Error: No se encontró la instalación base en ${ORIGINAL_ASAR}"
    exit 1
fi

rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

echo "1. Extrayendo app.asar original..."
npx -y asar extract "${ORIGINAL_ASAR}" "${TMP_DIR}"

echo "2. Copiando tema CSS e inyectando dependencia en index.html..."
cp "${THEME_CSS}" "${TMP_DIR}/out/renderer/claude-desktop-theme.css"

INDEX_HTML="${TMP_DIR}/out/renderer/index.html"
if ! grep -q "claude-desktop-theme.css" "${INDEX_HTML}"; then
    sed -i 's|</head>|    <link rel="stylesheet" href="./claude-desktop-theme.css">\n  </head>|' "${INDEX_HTML}"
fi

echo "3. Empaquetando nuevo app.asar..."
mkdir -p "${TARGET_DIR}"
npx -y asar pack "${TMP_DIR}" "${TARGET_DIR}/app.asar"

echo "=== Tema aplicado con éxito en ${TARGET_DIR}/app.asar ==="

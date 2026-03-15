#!/bin/bash

# Script para executar flutter pub get em todos os packages e no app do Yummy Log.
# Ordem: packages base, foundation, features (dependem deles), app raiz.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printf "${BLUE}Iniciando flutter pub get em todos os módulos...${NC}\n"
echo ""

# Ordem: contrato e l10n primeiro, foundation, features, por fim o app.
MODULES=(
  "packages/feature_contract"
  "packages/yummy_log_l10n"
  "modules/foundation/persistence"
  "modules/foundation/auth"
  "modules/features/conectar"
  "modules/features/diary"
  "modules/features/settings"
  "."
)

# Diretório raiz do projeto
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for module in "${MODULES[@]}"; do
  MODULE_PATH="$ROOT_DIR/$module"

  if [ -f "$MODULE_PATH/pubspec.yaml" ]; then
    printf "${BLUE}>>> Executando pub get em: ${GREEN}%s${NC}\n" "$module"
    (cd "$MODULE_PATH" && flutter pub get)
    echo ""
  else
    echo "Aviso: pubspec.yaml não encontrado em $module, pulando..."
  fi
done

printf "${GREEN}Concluído! Todos os módulos foram atualizados.${NC}\n"

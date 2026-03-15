#!/bin/bash

# Script para rodar testes com cobertura em todos os pacotes e exibir o total agregado.
# Uso:
#   ./coverage.sh              # Roda testes + cobertura e exibe o total
#   ./coverage.sh --quiet      # Idem, mas só mostra pacote + OK/FALHOU (sem saída dos testes)
#   ./coverage.sh --report-only # Só recalcula o total a partir dos coverage/ já gerados

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

REPORT_ONLY=false
QUIET=false
for arg in "$@"; do
  [ "$arg" = "--report-only" ] && REPORT_ONLY=true
  [ "$arg" = "--quiet" ] && QUIET=true
done

run_count=0
failed_packages=""

if [ "$REPORT_ONLY" = false ]; then
  if [ "$QUIET" = true ]; then
    printf "${BLUE}Rodando testes (modo quiet)...${NC}\n\n"
  else
    printf "${BLUE}Rodando testes com cobertura em todos os pacotes...${NC}\n\n"
  fi

  for f in $(find . -name "pubspec.yaml" -not -path "./.*"); do
    d=$(dirname "$f")
    if [ -d "$d/test" ] && [ -n "$(find "$d/test" -name '*_test.dart' -print 2>/dev/null | head -1)" ]; then
      if [ "$QUIET" = true ]; then
        if (cd "$d" && flutter test --coverage 2>/dev/null); then
          printf "  ${GREEN}OK${NC}   %s\n" "$d"
          ((run_count++)) || true
        else
          printf "  ${RED}FALHOU${NC} %s\n" "$d"
          failed_packages="${failed_packages}\n  - $d"
        fi
      else
        printf "${BLUE}>>> %s${NC}\n" "$d"
        if (cd "$d" && flutter test --coverage 2>&1); then
          ((run_count++)) || true
        else
          failed_packages="${failed_packages}\n  - $d"
        fi
        echo ""
      fi
    fi
  done

  if [ -n "$failed_packages" ]; then
    printf "${YELLOW}Atenção: alguns pacotes falharam:%s${NC}\n" "$failed_packages"
    echo ""
  fi
else
  run_count=$(find . -name "lcov.info" -path "*/coverage/*" 2>/dev/null | wc -l | tr -d ' ')
  printf "${BLUE}Recalculando a partir dos coverage/ existentes (%d pacotes).${NC}\n\n" "$run_count"
fi

# Merge: somar LF e LH de todos os lcov.info
printf "${BLUE}Calculando cobertura agregada...${NC}\n"

lcov_files=$(find . -name "lcov.info" -path "*/coverage/*" 2>/dev/null)
if [ -z "$lcov_files" ]; then
  echo "Nenhum arquivo lcov.info encontrado (coverage/). Rode os testes com --coverage primeiro."
  exit 1
fi

read -r total_lf total_lh <<< $(echo "$lcov_files" | xargs grep -h -E '^LF:|^LH:' 2>/dev/null | awk -F: '
  BEGIN { lf=0; lh=0 }
  $1=="LF" { lf+=$2 }
  $1=="LH" { lh+=$2 }
  END { print lf, lh }
')

if [ "${total_lf:-0}" -eq 0 ]; then
  echo "Nenhuma linha encontrada nos relatórios (LF=0)."
  exit 1
fi

pct=$(awk "BEGIN { printf \"%.1f\", 100*$total_lh/$total_lf }")

echo ""
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${GREEN}  Resumo de cobertura${NC}\n"
printf "${GREEN}  Pacotes com testes: %d${NC}\n" "$run_count"
printf "${GREEN}  Linhas totais (LF): %s${NC}\n" "$total_lf"
printf "${GREEN}  Linhas cobertas (LH): %s${NC}\n" "$total_lh"
printf "${GREEN}  Cobertura: %s%%${NC}\n" "$pct"
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

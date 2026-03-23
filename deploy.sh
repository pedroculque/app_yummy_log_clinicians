#!/usr/bin/env bash
# Deploy YummyLog for Clinicians – iOS e/ou Android.
# Uso: ./deploy.sh → escolhe flavor [dev|prod], depois plataforma [iOS|Android|ambos].
# Flavors: dev (development / Firebase App Distribution), prod (TestFlight / produção). Ver PROJECT.md e STATE.md.

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"

red='\e[31m'
green='\e[32m'
yellow='\e[33m'
white='\e[97m'
reset='\e[0m'
bold='\e[1m'
greenBg='\e[42m'
yellowBg='\e[43m'
magentaBg='\e[45m'
cyan='\e[36m'

you_re_here="Estamos rodando a seguinte lane: "

flavor='dev'
platform='both'

run_fastlane() {
  fastlane "$1"
}

select_flavor() {
  echo "YummyLog for Clinicians – Deploy"
  printf "\n${red}${bold}[1]${reset}${green}: [dev] Development (Firebase App Distribution)${reset}\n"
  printf "${yellow}${bold}[2]${reset}${green}: [prod] Production (TestFlight / App Store / Play)${reset}\n"
  printf "${green}Escolha o flavor (Enter = [dev]): ${reset}"
  read -r value

  if [ "$value" = "2" ]; then
    flavor="prod"
  fi
}

select_platform() {
  echo ""
  printf "${cyan}${bold}Plataforma${reset}\n"
  printf "${red}${bold}[1]${reset}${green}  iOS apenas${reset}\n"
  printf "${yellow}${bold}[2]${reset}${green}  Android apenas${reset}\n"
  printf "${green}${bold}[3]${reset}${green}  Ambos (iOS + Android)${reset} ${bold}— padrão${reset}\n"
  printf "${green}Escolha (Enter = ambos): ${reset}"
  read -r value

  case "$value" in
    1) platform="ios" ;;
    2) platform="android" ;;
    3 | '') platform="both" ;;
    *)
      printf "${yellow}Opção não reconhecida; usando ambos.${reset}\n"
      platform="both"
      ;;
  esac
}

deploy() {
  # Sempre a partir da raiz do repositório (onde está este script)
  cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

  select_flavor
  select_platform

  if [ "$platform" = "ios" ] || [ "$platform" = "both" ]; then
    cd ios || exit 1
    printf "\n${you_re_here}${white}${bold}${greenBg}$(pwd)${reset}\n"
    run_fastlane "$flavor"
    cd ..
  fi

  if [ "$platform" = "android" ] || [ "$platform" = "both" ]; then
    cd android || exit 1
    printf "\n${you_re_here}${white}${bold}${greenBg}$(pwd)${reset}\n"
    run_fastlane "$flavor"
  fi
}

deploy

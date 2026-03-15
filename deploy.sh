#!/usr/bin/env bash
# Deploy YummyLog for Clinicians – iOS (e opcionalmente Android).
# Uso: ./deploy.sh → escolhe flavor [dev] ou [prod] e roda fastlane na pasta atual.
# Flavors: dev (development/.stg), prod (production). Ver PROJECT.md e STATE.md.

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

run_fastlane() {
  fastlane "$1"
}

select_flavor() {
  echo "YummyLog for Clinicians – Deploy"
  printf "\n${red}${bold}[1]${reset}${green}: [dev] Development (Firebase App Distribution)${reset}\n"
  printf "${yellow}${bold}[2]${reset}${green}: [prod] Production (TestFlight / App Store)${reset}\n"
  printf "${green}Escolha o flavor (Enter = [dev]): ${reset}"
  read -r value

  if [ "$value" = "2" ]; then
    flavor="prod"
  fi
}

deploy() {
  select_flavor
  # iOS (TestFlight / App Store ou Firebase App Distribution)
  cd ios || exit 1
  printf "\n${you_re_here}${white}${bold}${greenBg}$(pwd)${reset}\n"
  run_fastlane "$flavor"
  # Android – desabilitado; reativar quando for usar deploy Android
  # cd ../android || exit 1
  # printf "\n${you_re_here}${white}${bold}${greenBg}$(pwd)${reset}\n"
  # run_fastlane "$flavor"
}

deploy
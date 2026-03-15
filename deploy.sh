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
 emoji_alien=👽
 
 you_re_here="Estamos rodando a seguinte lane: "
 
 flavor='dev'
 
 run_fastlane() {
    #  bundle exec fastlane $1
    fastlane $1
 }
 
 select_flavor() {
     echo "Welcome to the show\n"
     printf "${red}${bold}[1]${reset}${green}: [dev] Development${reset} \n"
     printf "${yellow}${bold}[2]${reset}${green}: [prod] Production${reset}"
     printf "${green}\nPlease select your flavor, default is ${magentaBg}${white}[dev]${reset} (Press ${white}${yellowBg}enter${reset} to use the default): ${reset}"
     read value
 
     if [ "$value" = "2" ]
     then
       flavor="prod"
     fi
 }
 
 deploy() {
     select_flavor
     # iOS (TestFlight / App Store)
     cd ios
     printf "\n${you_re_here}${white}${bold}${greenBg}$(pwd)${reset}\n"
    run_fastlane $flavor
    # Android (Firebase App Distribution / Google Play) — desabilitado; reativar quando for usar deploy prod Android
    # cd ../android
    # printf "\n${you_re_here}${white}${bold}${greenBg}$(pwd)${reset}\n"
    # run_fastlane $flavor
 }
 
 deploy
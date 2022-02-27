#!/bin/bash -e
LOCALDIR=$(pwd)
RED='\033[0;31m'
NC='\033[0m'

info()
{
    printf "\n-- Tata Sky Playlist Auto-Updater --"
    printf "\nAuthor: ST\n"
    echo "GitHub Profile: https://github.com/Sanju2105"
    printf '\n'
    printf "\n * This Script is for Automatically generating the Tata Sky M3U Playlists Everyday keep the Playlist URL Constant, It's only your IPTV Player which needs to refresh for every 24 Hrs. I would like to thank Gaurav Thakkar sincerely for his work on Playlist Generator. \n* Enter only valid information \n\nNow, Get ready to dwell into this journey. \n"
    echo "-------------------------------------------------"
    tput sgr0;
}

take_input()
{
    echo "Please Enter the required details below to proceed further: "
    echo " "
    read -p " Enter your Tata Sky Subscriber ID: " sub_id;
    read -p " Enter your Registered Mobile Number without the country code: " tata_mobile;
    read -p " Enter your Tata Sky OTP: " tata_OTP;
    read -p " Enter your GitHub Token: " git_token;
}

take_vars()
{
    if [[ ! -f "$LOCALDIR/.usercreds" ]]; then
    take_input;
    ask_playlist_type;
    main;
    else
    ask_direct_login;
    sleep 3;
    fi
}

extract_git_vars()
{
    git_id=$(curl -s -H "Authorization: token $git_token"     https://api.github.com/user | grep 'login' | sed 's/login//g' | tr -d '[:punct:] ')
    git_mail=$(curl -s -H "Authorization: token $git_token"     https://api.github.com/user/emails | grep 'email' | head -n1 | tr -d '", ' | sed 's/email://g')
}

initiate_setup()
{
    if [[ $OSTYPE == 'linux-gnu'* ]]; then
    echo "Please wait while the installation takes place..."
    printf "Please Enter your password to proceed with the setup: "
    sudo echo '' > /dev/null 2>&1
    sudo apt update
    sudo apt install python3.9 expect -y || { echo -e "${RED}Something went wrong, Try running the script again.${NC}"; exit 1; }
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3.9 get-pip.py
    pip3.9 install requests
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh
    echo "Installation done successfully!"
    
    elif [[ $OSTYPE == 'linux-android'* ]]; then
    if [[ $(echo "$TERMUX_VERSION" | cut -c 3-5) -ge "117" ]];then
    echo "Please wait while the installation takes place..."
    pkg install git gh ncurses-utils expect python gettext -y || { echo -e "${RED}Something went wrong, Try running the script again.${NC}"; exit 1; }
    pip install requests || { echo -e "${RED}Something went wrong, Try running the script again.${NC}"; exit 1; }
    echo "Installation done successfully!"
    else
    echo -e "Please use Latest Termux release, i.e, from FDroid (https://f-droid.org/en/packages/com.termux/)";
    exit 1;
    fi
    else
    echo -e "${RED}Platform not supported, Exiting...${NC}"; sleep 3; exit 1;
    fi
    
    touch .setupinitiated

}

save_creds()
{
    if [[ ! -f "$LOCALDIR/.usercreds" ]]; then
    echo "Saving usercreds so that you don't have to login again..."
    printf "sub_id=\'$sub_id\'\ntata_mobile=\'$tata_mobile\'\ntata_pass=\'$tata_pass\'\ngit_token=\'$git_token\'\n" > $LOCALDIR/.usercreds
    fi
}

ask_direct_login()
{
    read -p "File .usercreds already exists, Would you like to take all the inputs from it? (y/n): " response;
    if [[ "$response" == 'y' ]]; then
    source $LOCALDIR/.usercreds
    ask_playlist_type;
    main;
    elif [[ "$response" == 'n' ]]; then
    rm .usercreds;
    start && main;
    else
    echo "Invalid option chosen, Try again..." && ask_direct_login;
    fi
}

check_if_repo_exists()
{
    check_repo=$(curl -i -s -H "Authorization: token $git_token"     https://api.github.com/user/repos | grep 'TataSkyIPTV-Daily') || true
    if [[ -n $check_repo ]]; then
    repo_exists='true'
    ask_user_to_select;
    else
    repo_exists='false'
    fi
}

ask_user_to_select()
{
    printf "\n Repo named 'TataSkyIPTV-Daily' already exists, What would you like to perform? \n\n"
    echo "   1. Re-run the script & Update my repo with same playlist."
    echo "   2. Maintain other playlist with another Tata Sky Account"
    echo "   3. Generate new playlist with new link"
    printf '\n'
    while true; do
    read -p "Select from the options above: " selection
    case $selection in
    '1')echo "Option 1 chosen"; break;;
    '2')echo "Option 2 chosen"; break;;
    '3')echo "Option 3 chosen"; break;;
    *)echo "Invalid option chosen, Please try again...";;
    esac
    done
}

take_vars_from_existing_repo()
{
    if [[ $selection == '1' ]]; then
    dir=$(curl -s "https://$git_token@raw.githubusercontent.com/$git_id/TataSkyIPTV-Daily/main/.github/workflows/Tata-Sky-IPTV-Daily.yml" | grep 'gist' | sed 's/.*\///g')
    gist_url="https://$git_token@gist.github.com/$dir"
    fi
}

ask_playlist_type()
{
    printf "\nWhich type of playlist would you like to have? \n\n"
    echo "  1. Kodi & Tivimate Compatible"
    printf "  2. Tivimate & OTT Navigator Compatible\n\n"
    read -p "Select from the options above: " playlist_type;
    while true; do
    case $playlist_type in
    '1')echo "Option 1 chosen"; break;;
    '2')echo "Option 2 chosen"; break;;
    *)echo "Invalid option chosen, Please try again...";;
    esac
    done
}

start()
{
    if [[ $OSTYPE == 'linux-gnu'* ]]; then
    packages='curl gh expect python3 python3-pip'
    for package in $packages; do
    dpkg -s $package > /dev/null 2>&1 || initiate_setup;
    done
    clear
    tput setaf 41; curl -s 'https://pastebin.com/raw/N3TprJxp' || { tput setaf 9; echo " " && echo "This script needs active Internet Connection, Please Check and try again."; exit 1; }
    info;
    python='python3.9'
    take_vars;
    
    
    elif [[ $OSTYPE == 'linux-android'* ]]; then
    packages='gh expect python ncurses-utils gettext'
    for package in $packages; do
    dpkg -s $package > /dev/null 2>&1 || initiate_setup;
    done
    clear
    tput setaf 41; curl -s 'https://pastebin.com/raw/RHe4YyY2' || { tput setaf 9; echo " " && echo "This script needs active Internet Connection, Please Check and try again."; exit 1; }
    info;
    python='python3'
    take_vars;
    else
    echo -e "${RED}Platform not supported, Exiting...${NC}"; sleep 3; exit 1;
    fi
}

create_gist()
{
    if [[ $selection == "2" || $repo_exists == 'false' || $selection == '3' ]]; then
    echo "Initial Test" >> allChannelPlaylist.m3u
    gh gist create allChannelPlaylist.m3u | tee gist_link.txt >> /dev/null 2>&1
    sed -i "s/gist/$git_token@gist/g" gist_link.txt
    gist_url=$(cat gist_link.txt)
    dir="${gist_url##*/}"
    rm allChannelPlaylist.m3u gist_link.txt
    gh repo create TataSkyIPTV-Daily --private -y >> /dev/null 2>&1 || true
    fi
}

dynamic_push()
{
    git add .
    git commit --author="ST<st21051989@gmail.com>" -m "Adapt Repo for auto-loop"
    if [[ "$selection" == "1" || "$selection" == '3' ]]; then
    git branch -M main
    git push -f --set-upstream origin main;
    elif [[ "$selection" == "2" ]]; then
    branch_name=$(echo "$dir" | cut -c 1-6)
    git branch -M $branch_name
    git push -f --set-upstream origin $branch_name
    elif [[ "$repo_exists" == 'false' ]]; then
    git branch -M main
    git push --set-upstream origin main
    fi
}

main()
{
    extract_git_vars;
    git config --global user.name "$git_id"
    git config --global user.email "$git_mail"
    check_if_repo_exists;
    git clone https://github.com/Tivimate/Tata-Sky-IPTV >> /dev/null 2>&1 || { rm -rf Tata-Sky-IPTV; git clone https://github.com/Tivimate/Tata-Sky-IPTV; } 
    cd Tata-Sky-IPTV/code_samples/
    if [[ $playlist_type == '2' ]]; then git revert --no-commit f291bf7be579bcd726208a8ce0d0dd1a0bc801e1; fi
    cat $LOCALDIR/dependencies/script.exp | sed "s/python3/$python/g" > script.exp
    chmod 755 script.exp
    pass=$(echo "$tata_pass" | sed 's#\$#\\\\$#g' )
    sed -i "s/PASSWORD/$pass/g" script.exp
    sed -i "s/SUB_ID/$sub_id/g" script.exp
    sed -i "s/MOB_NO/$tata_mobile/g" script.exp
    ./script.exp || { echo "Something went wrong."; exit 1; }
    echo "$git_token" >> mytoken.txt
    gh auth login --with-token < mytoken.txt
    rm mytoken.txt script.exp
    cd ..
    create_gist;
    take_vars_from_existing_repo;
    mkdir -p $LOCALDIR/Tata-Sky-IPTV/.github/workflows && cd $LOCALDIR/Tata-Sky-IPTV/.github/workflows
    export dir=$dir
    export gist_url=$gist_url
    export git_id=$git_id
    export git_token=$git_token
    export git_mail=$git_mail
    cat $LOCALDIR/dependencies/Tata-Sky-IPTV-Daily.yml | envsubst > Tata-Sky-IPTV-Daily.yml
    cd ../..
    echo "code_samples/__pycache__" > .gitignore && echo "allChannelPlaylist.m3u" >> .gitignore && echo "userSubscribedChannels.json" >> .gitignore
    git remote remove origin
    git remote add origin "https://$git_token@github.com/$git_id/TataSkyIPTV-Daily.git"
    dynamic_push;
    git clone ${gist_url} >> /dev/null 2>&1
    cd ${dir} && rm allChannelPlaylist.m3u && mv ../code_samples/allChannelPlaylist.m3u .
    git add .
    git commit -m "Initial Playlist Upload"
    git push >> /dev/null 2>&1 || { tput setaf 9; printf 'Something went wrong!\n ERROR Code: 65x00a\n'; exit 1; }
    save_creds;
    tput setaf 51; echo "Successfully created your new private repo." && printf "Check your new private repo here: ${NC}https://github.com/$git_id/TataSkyIPTV-Daily\n" && tput setaf 51; printf "Check Your Playlist URL here: ${NC}https://gist.githubusercontent.com/$git_id/$dir/raw/allChannelPlaylist.m3u \n"
    if [[ "$selection" == '2' ]]; then tput setaf 51; echo -e "Check your other playlist branch here: ${NC}https://github.com/$git_id/TataSkyIPTV-Daily/tree/$dir"; fi
    tput setaf 51; printf "You can directly paste this URL in Tivimate/OTT Navigator now, No need to remove hashcode\n"
    tput bold; printf "\n\nFor Privacy Reasons, NEVER SHARE your GitHub Tokens, Tata Sky Account Credentials and Playlist URL TO ANYONE. \n"
    tput setaf 51; printf "Using this script for Commercial uses is NOT PERMITTED. \n\n"
    tput setaf 51; echo "Script by Shravan, Please do star my repo if you've liked my work :) "
    tput setaf 51; echo "Credits: Gaurav Thakkar (https://github.com/ForceGT) & Manohar Kumar"
    tput setaf 51; echo "My Github Profile: https://github.com/Shra1V32"
    printf '\n\n'
    rm -rf $LOCALDIR/Tata-Sky-IPTV;
    echo "Press Enter to exit."; read junk;
    tput setaf init;
}
start;



#!/usr/bin/env bash

# CREATOR: mike.lu@hp.com
# CHANGE DATE: 08/08/2024
__version__="1.3"


CheckNetwork() {
    wget -q --spider www.google.com > /dev/null
    [[ $? != 0 ]] && echo -e "\e[31mNo Internet connection! Please check and retry.\n\e[0m" && exit || :
}

UpdateScript() {
    release_url=https://api.github.com/repos/DreamCasterX/SysInfo/releases/latest
    new_version=$(wget -qO- "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    release_note=$(wget -qO- "${release_url}" | grep '"body":' | awk -F\" '{print $4}')
    tarball_url="https://github.com/DreamCasterX/SysInfo/archive/refs/tags/${new_version}.tar.gz"
    if [[ $new_version != $__version__ ]]; then
        echo -e "⭐️ New version found!\n\nVersion: $new_version\nRelease Note:\n$release_note"
        sleep 2
        echo
        echo "╭───────────────────────────────────────╮"
        echo "│     Downloading the latest update     │"
        echo "│                                       │"
        echo "╰───────────────────────────────────────╯"
        echo
        pushd "$PWD" > /dev/null 2>&1
        wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".SysInfo.tar.gz" "${tarball_url}"
        if [[ -e ".SysInfo.tar.gz" ]]; then
            tar -xf .SysInfo.tar.gz -C "$PWD" --strip-components 1 SysInfo-$new_version/SysInfo.sh > /dev/null 2>&1
            rm -f .SysInfo.tar.gz
            popd > /dev/null 2>&1
            sleep 3
            sudo chmod 755 SysInfo.sh
            echo -e "\e[32mDone!\e[0m\nPlease run SysInfo.sh again.\n\n" ; exit 1
        else
            echo -e "\n\e[31mUpdate failed.\e[0m" ; exit 1
        fi
    else
        echo
        echo "╭───────────────────────────────────────╮"
        echo "│        Downloading config file        │"
        echo "│                                       │"
        echo "╰───────────────────────────────────────╯"
        echo
        pushd "$PWD" > /dev/null 2>&1
        wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".SysInfo.tar.gz" "${tarball_url}"
        if [[ -e ".SysInfo.tar.gz" ]]; then
            tar -xf .SysInfo.tar.gz -C "$PWD" --strip-components 1 SysInfo-$new_version/config.jsonc > /dev/null 2>&1
            rm -f .SysInfo.tar.gz
            popd > /dev/null 2>&1
            sleep 3
            sudo chmod 755 config.jsonc
            echo -e "\e[32mDone!\e[0m"
        else
            echo -e "\n\e[31mDownload config file failed.\e[0m" ; exit 1
        fi			
    fi
}

Install_fastfetch() {	
    echo
    echo "╭───────────────────────────────────────╮"
    echo "│        Installing fastfetch           │"
    echo "│                                       │"
    echo "╰───────────────────────────────────────╯"
    echo
    release_url=https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest
    new_version=$(wget -qO- "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    deb_url="https://github.com/fastfetch-cli/fastfetch/releases/download/$new_version/fastfetch-linux-amd64.deb"
    rpm_url="https://github.com/fastfetch-cli/fastfetch/releases/download/$new_version/fastfetch-linux-amd64.rpm"
    sudo update-pciids -q  # Update GPU ids
    [[ -f /usr/bin/apt ]] && PKG=apt || PKG=dnf
    if [[ $PKG == 'apt' ]]; then 
        wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".fastfetch.deb" "${deb_url}"
        sudo dpkg -i .fastfetch.deb > /dev/null && rm -f .fastfetch.deb > /dev/null && fastfetch --gen-config-force > /dev/null
        mv config.jsonc ~/.config/fastfetch/	
        [[ ! `grep 'Start SysInfo' ~/.bashrc` ]] && echo -e '\n# Start SysInfo\nfastfetch --logo none\n\n' >> ~/.bashrc
        echo -e "\e[32mDone!\e[0m\nOpen a new Terminal to see the changes.\n" 
        source ~/.bashrc
    elif [[ $PKG == 'dnf' ]]; then 
        wget --quiet --no-check-certificate --tries=3 --waitretry=2 --output-document=".fastfetch.rpm" "${rpm_url}"
        sudo rpm -i .fastfetch.rpm > /dev/null && rm -f .fastfetch.rpm > /dev/null && fastfetch --gen-config-force > /dev/null
        mv config.jsonc ~/.config/fastfetch/	
        [[ ! `grep 'Start SysInfo' ~/.bashrc` ]] && echo -e '\n# Start SysInfo\nfastfetch --logo none\n\n' >> ~/.bashrc
        echo -e "\e[32mDone!\e[0m\n\n" 
        source ~/.bashrc
    fi
}

# RESTRICT USER ACCOUNT
[[ $EUID == 0 ]] && echo -e "⚠️ Please run as non-root user.\n" && exit
CheckNetwork 
UpdateScript
Install_fastfetch






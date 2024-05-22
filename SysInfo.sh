#!/usr/bin/env bash

# CREATOR: mike.lu@hp.com
# CHANGE DATE: 05/22/2024
__version__="1.0"



CheckNetwork() {
	wget -q --spider www.google.com > /dev/null
	[[ $? != 0 ]] && echo -e "\e[31mNo Internet connection! Please check and retry.\n\e[0m" && exit || :
}

UpdateScript() {
	[[ ! -f /usr/bin/curl ]] && sudo apt update && sudo apt install -y curl
	release_url=https://api.github.com/repos/DreamCasterX/SysInfo/releases/latest
	new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
	release_note=$(curl -s "${release_url}" | grep '"body":' | awk -F\" '{print $4}')
	tarball_url="https://github.com/DreamCasterX/SysInfo/archive/refs/tags/${new_version}.tar.gz"
	if [[ $new_version != $__version__ ]]
	then
		echo -e "⭐️ New version found!\n\nVersion: $new_version\nRelease Note:\n$release_note"
		sleep 2
		echo
		echo "╭───────────────────────────────────────╮"
		echo "│     Downloading the latest update     |"
		echo "│                                       │"
		echo "╰───────────────────────────────────────╯"
		echo
		pushd "$PWD" > /dev/null 2>&1
		curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".SysInfo.tar.gz" "${tarball_url}"
		if [[ -e ".SysInfo.tar.gz" ]]; then
			tar -xf .SysInfo.tar.gz -C "$PWD" --strip-components 1 SysInfo-$new_version/SysInfo.sh SysInfo-$new_version/config.jsonc > /dev/null 2>&1
			rm -f .SysInfo.tar.gz
			popd > /dev/null 2>&1
			sleep 3
			sudo chmod 755 config.jsonc
			sudo chmod 755 SysInfo.sh
			echo -e "\e[32mDone!\e[0m\nPlease run SysInfo.sh again.\n\n" ; exit 1
		else
			echo -e "\n\e[31mUpdate failed.\e[0m" ; exit 1
		fi
	else
		echo
		echo "╭───────────────────────────────────────╮"
		echo "│        Downloading config file        |"
		echo "│                                       │"
		echo "╰───────────────────────────────────────╯"
		echo
		pushd "$PWD" > /dev/null 2>&1
		curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".SysInfo.tar.gz" "${tarball_url}"
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
	echo "│        Installing fastfetch           |"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	[[ ! -f /usr/bin/curl ]] && sudo apt update && sudo apt install -y curl
	release_url=https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest
	new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
	deb_url="https://github.com/fastfetch-cli/fastfetch/releases/download/$new_version/fastfetch-linux-amd64.deb"
	curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".fastfetch.deb" "${deb_url}"
	sudo dpkg -i .fastfetch.deb > /dev/null && rm -f .fastfetch.deb > /dev/null && fastfetch --gen-config-force > /dev/null
	mv config.jsonc ~/.config/fastfetch/	
	[[ ! `grep 'Start SysInfo' ~/.bashrc` ]] && echo -e '\n# Start SysInfo\nfastfetch --logo none\n\n' >> ~/.bashrc
	echo -e "\e[32mDone!\e[0m\nOpen a new Terminal to see the changes.\n" 
	source ~/.bashrc
}


CheckNetwork && UpdateScript && Install_fastfetch

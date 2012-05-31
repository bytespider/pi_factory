#!/bin/bash

# Define colors
GREEN="\033[0;32m"
RED="\033[1;31m"
RESET="\033[0m"

check_dependencies() {
	local notfound=0
	local deps=( grep awk sed )

	for dep in ${deps[*]}
	do
		if [ -z $(which $dep) ]; then
			echo -e "${dep}: \t${RED}not found${RESET}"
			notfound=1
		else
			echo -e "${dep}: \t${GREEN}found${RESET}"
		fi
	done

	return $notfound
}

display_menu() {
	IFS=$'\n'
	local return_value=$4
	local eval items=($1)

	local i=0
	local count=${#items[*]}
	let count=count-1

	local length=0
	for j in ${items[@]}; do
		if [ $length -lt ${#j} ]; then
			length=${#j}
		fi
	done
	let length=length+4

	echo
	echo $2
	tput sc

	while [ 0 ]; do
		tput rc

		if [ $i -lt 0 ]; then i=0; fi
		if [ $i -eq ${#items[*]} ]; then let i=i-1; fi

		for ((a=0; a<=$count; a++)); do

			if [ $a -eq $i ]; then
				tput rev
			else
				tput dim
			fi

			printf "\r%*s" $length ""
			echo -en "\r"

			if [ $a -eq $i ]; then
				echo -en " > "
			else
				echo -en "   "
			fi
			echo -e "${items[a]} ${RESET}"
		done;

		read -sn 1 twiddle
		case "$twiddle" in
			"B")
				let i=i+1
				;;
			"A")
				let i=i-1
				;;
			"")
				eval "$3 ${items[$i]}"
				read -sn 1 confirm
				if [ "$confirm" == "y" -o "$confirm" == "Y" ]; then
					break
				else
					tput cuu1
					tput el
					tput cuu1
					tput el
					tput cuu1
					tput el

					tput rc
				fi
				;;
		 esac
	done

	eval $return_value="'${items[$i]}'"
}

choose_sd() {
	local return_value=$1

	display_menu "$(df -h | grep "^/")" "Please select the drive you wish to install to" confirm_sd choice
	eval $return_value='$choice'
}

confirm_sd() {
	local drive=$(echo "$1" | awk '{print $1}')
	local dev=$(diskutil info ${drive} | sed -En 's/ *Part Of Whole: *(.*)/\1/p')
	local mountpoint=$(diskutil info ${drive} | sed -En 's/ *Mount Point: *(.*)/\1/p')

	echo
	echo -e "${RED}WARNING: This will wipe all data on the drive.${RESET}"
	echo "Are you sure you want to install to ${mountpoint} on ${dev} (y/N)?"
}

search_for_distro() {
		local return_value=$1

		distros=$(find . -name "*.img" -maxdepth 1)

		if [ -z $distros ]; then
			echo "ERROR: No distribution image found."
			exit
		fi

		if [ ${#distros[*]} -eq 1 ]; then
			dist=$distros
		else
			display_menu "${distros}" "Please select the distribution you wish to install" confirm_distro dist
		fi

		eval $return_value='$dist'
}

confirm_distro() {
	local dist=$(echo $1 | sed -En 's/.\/(.*)/\1/p')

	echo
	echo "You've selected to install ${dist}. Correct (y/N)?"
}

flash_card() {
	echo "Installing $1 to $2..."
	local filesize="$(stat -r $1 | awk '{print $8}')"

	# dd the image whilst displaying a progress bar
	dd bs=1m if=$1 2>/dev/null | pv -pe -s $filesize | dd bs=1m of=$2 2>/dev/null
	return 1
}

# just incase the last program didn't clean up properly
tput sgr0

# OS name
OS=$(uname -s)

# check dependencies
check_dependencies

choose_sd sd
drive=$(echo "${sd}" | awk '{print $1}')
dev=$(diskutil info ${drive} | sed -En 's/ *Part Of Whole: *(.*)/\1/p')
node=$(diskutil info ${dev} | sed -En 's/ *Device Node: *(.*)/\1/p')

# unmount the drive
disktool -u $dev

search_for_distro distro

flash_card $distro $node

# eject the drive
diskutil eject $node

echo "Your Pi is now complete. Thank you for visiting the Pi Factory."

#!/bin/bash

function isInt
{
	num="$1"

	if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
		return 0
	fi

	return 1
}

function isFloat
{
	num="$1"

	if ! [[ "$num" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
		return 0
	fi

	return 1
}

function checkMode
{
	file="$1"
	mode="$2"

	if [ ! -e "$file" -a "$mode" != "c" ]; then
		error "file does not exist '$file'"
	fi
	case $mode in
		r)
			if [ ! -r "$file" ]; then
				error "file is unreadable '$file'"
			fi
			;;
		w)
			if [ ! -r "$file" ]; then
				error "file is not writable '$file'"
			fi
			;;
		x)
			if [ ! -x "$file" ]; then
				error "file is not executable '$file'"
			fi
			;;
		c)
			parent=`dirname "$file"`
			if [ ! -w "$parent" ]; then
				error "cannot create file in '$parent'"
			fi
			;;
	esac

	return 1;
}

function dirBackup
{
	dir="$1"

	if [ -e "$dir" ]; then
        	newdir="$dir-`date +'%Y-%M-%d_%H.%M.%S'`"
        	echo -n "Moving directory $dir to $newdir... "
        	if [ ! -w "$dir" ]; then
                	error "permission denied."
		else
                	mv "$dir" "$newdir" || error "failed."
        	fi
	else
		return 0
	fi

        echo "Done." && return 1
}

function error
{
	echo "[ERROR]: $1"
	exit 1
}

function warn
{
	caller=`caller 1`
	if [ $caller ]; then
		echo -n "$caller ";
	fi
	echo "[WARN]: $1"
}

function check
{
	if [ -z  `which "$1"` ]; then
		[ -n "$2" ] && error "Could not find command $1 (hint: $2)"
		error "Could not find command $1"
	fi
}

function execute
{
	cmd="$1"
	verbose="$2"
	
	[ -n "$cmd" ] || error "No command supplied to execute function."
	
	if [ "$verbose" = "0" ]; then
		cmd="$cmd &> /dev/null"
	else
		echo "$cmd"
	fi

	eval "$cmd" && return $?
}

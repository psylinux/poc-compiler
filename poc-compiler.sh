#!/bin/bash
#
## Author: Marcos Azevedo
# Date: 2018-12-29
# Version: 0.1
# Name: poc-compiler.sh
# 
## Requirements:
# 	For Debian/Ubuntu/Kali:
# 	apt-get update && apt-get install nasm gcc
# 
## Description:
# 	Basic Bash Script to compile the PoCs without any protection
# 	It receives files with extension .c or .nasm and compiles it to your current machine archtecture
#

#----------------------
#    Terminal Colors
#----------------------
BOLD_YELLOW="\e[01;33m"
BOLD_GREEN="\e[01;32m"
GREEN="\e[00;32m"
RED="\e[31m"
END="\e[00m"

#----------------------
#   Checking args
#----------------------
if [ $# -eq 0 ]; then
	echo -e "Usage:\n\t$0 $GREEN input_file{.c|.nasm} $END"
	exit 0
fi

#----------------------
# Getting the Arch
#----------------------
MACHINE_TYPE=`uname -m`

#----------------------
# Disabling ASLR/PIE 
#----------------------
echo -e "$BOLD_YELLOW [+] Warning: $END Disabling ASLR/PIE kernel protection"
echo 0 > /proc/sys/kernel/randomize_va_space

if [ "$1" != "" ]; then
	fullfilename=$1
	filename=$(basename "$fullfilename")
	fname="${filename%.*}"
	ext="${filename##*.}"
	
	echo -e "$BOLD_YELLOW [+] Warning: $END Your current arch is $GREEN<${MACHINE_TYPE}>$END"
	
	if [ $ext == "c" ]; then
		echo -e "$BOLD_GREEN [+] Compiling: $END The C source $GREEN<$filename>$END into the output $GREEN<$fname-${MACHINE_TYPE}.bin>$END"
		gcc -fno-stack-protector -z execstack -no-pie $filename -o $fname-${MACHINE_TYPE}.bin
	elif [ $ext == "nasm" ]; then
		echo -e "$BOLD_GREEN [+] Compiling: $END The NASM source $GREEN<$filename>$END into the output $GREEN<$fname-${MACHINE_TYPE}.bin>$END"
		if [ ${MACHINE_TYPE} == "x86_64" ]; then
			nasm -felf64 $filename -o $fname-${MACHINE_TYPE}.o
		else
			nasm -felf32 $filename -o $fname-${MACHINE_TYPE}.o
		fi
			ld $fname-${MACHINE_TYPE}.o -o $fname-${MACHINE_TYPE}.bin
	fi
fi

echo -e "$BOLD_GREEN [+] Checking: $END Summary of the security features of the $GREEN<$fname-${MACHINE_TYPE}.bin>$END \n"
echo -e "$RED---------------------------------------------------------------------$END"
./checksec.sh --file $fname-${MACHINE_TYPE}.bin
echo -e "$RED---------------------------------------------------------------------$END"


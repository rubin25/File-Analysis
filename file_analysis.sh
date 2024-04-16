#!/bin/bash

alias myscript="file_analysis.sh"

#Declared variables
TARGET_FILE="${1}"		 	#Target file to scan
MAIN_DIR="export_forensics_results"	#Directory to store results
TARGET_SUBDIR="dir_${TARGET_FILE}"	#Directory to store results
FILE_TRID="${MAIN_DIR}/${TARGET_SUBDIR}/trid_${TARGET_FILE}"	   #Directory to store trid results
FILE_EXIF="${MAIN_DIR}/${TARGET_SUBDIR}/exif_${TARGET_FILE}"	   #Directory to store exiftool results
FILE_SCAN="${MAIN_DIR}/${TARGET_SUBDIR}/scan_${TARGET_FILE}"	   #Directory to store scan results
FILE_HASH="${MAIN_DIR}/${TARGET_SUBDIR}/hash_${TARGET_FILE}"	   #Directory to store hash results
FILE_STR="${MAIN_DIR}/${TARGET_SUBDIR}/str_${TARGET_FILE}"	   #Directory to store str results
FILE_YARA="${MAIN_DIR}/${TARGET_SUBDIR}/yara_${TARGET_FILE}"	   #Directory to store yara results
FILE_URLS="${MAIN_DIR}/${TARGET_SUBDIR}/urls_${TARGET_FILE}"	   #Directory to store yara URL and IP results
FILE_BIN="${MAIN_DIR}/${TARGET_SUBDIR}/binwalk_${TARGET_FILE}"   #Directory to store binwalk results
FILE_PESEC="${MAIN_DIR}/${TARGET_SUBDIR}/pesec_${TARGET_FILE}"     #Directory to store pesec results
FILE_PACK="${MAIN_DIR}/${TARGET_SUBDIR}/pack_${TARGET_FILE}"	   #Directory to store packer results
FILE_FULL="${MAIN_DIR}/${TARGET_SUBDIR}/full_${TARGET_FILE}"	   #Directory to store full results

# -----------------------DO NOT CHANGE CODE BELOW THIS LINE -----------------------------

# Ask to delete the previously created export directory
while true; do
	read -p "Do you want to delete the previously created export directory? (y/n)" yn
	case $yn in
		[Yy]* ) rm -rf ${MAIN_DIR}; break;;
		[Nn]* ) break;;
	esac
done

# Ensure a filename was entered
if [ -z "$1" ]
then
	echo -e "Usage: runscript <file>\n"
	exit 1
fi

# Ensure target is a file
if [ -f !"$1" ]
then
	echo -e "[-] $1 is not a file\n"
	exit 1
fi

# Create primary directory, if needed
if [ -d "${MAIN_DIR}" ]
then
	echo -e "[-] Results directory already exists, skipping...\n"
else
	echo -e "[+] Creating Results directory (/${MAIN_DIR})\n"
	mkdir ${MAIN_DIR}
fi

# Create target subdirectory, if needed
if [ -d "${MAIN_DIR}/${TARGET_SUBDIR}" ]
then
	echo -e "[-] Target subdirectory already exists, skipping...\n"
else
	echo -e "[+] Creating target subdirectory (/${MAIN_DIR}/${TARGET_SUBDIR})\n"
	cd ${MAIN_DIR}
	mkdir ${TARGET_SUBDIR}
	cd ..
fi

# -----------------------DO NOT CHANGE CODE ABOVE THIS LINE -----------------------------

# If files already exist, delete to rerun scans
rm -f ${FILE_TRID}
rm -f ${FILE_EXIF}
rm -f ${FILE_SCAN}
rm -f ${FILE_HASH}
rm -f ${FILE_STR}
rm -f ${FILE_YARA}
rm -f ${FILE_URLS}
rm -f ${FILE_BIN}
rm -f ${FILE_PESEC}
rm -f ${FILE_PACK}
rm -f ${FILE_FULL}

# Add more tools below but don't forget to declare the new variables and also add them to the REMOVE list above

# Run trid
echo -e "==============================[ TRID ]================================\n" >> ${FILE_FULL}
echo "[+] Identifying the correct file format"
echo -e "-----------------------------------------------------------------------------"
echo -e "\033[3mQUICK TrID ANALYSIS PREVIEW, THIS WILL BE INCLUDED IN THE FINAL REPORTS\033[0m"
trid ${TARGET_FILE} # for immediate user view
echo -e "-----------------------------------------------------------------------------"
trid ${TARGET_FILE} >> ${FILE_TRID}
cat -n ${FILE_TRID} >> ${FILE_FULL}
echo -e "Note: If the file is a MS Office file, use the OLEVBA tools"
echo ""

# Run exiftool
echo -e "==============================[ EXIFTOOL ]================================\n" >> ${FILE_FULL}
echo "[+] Identifying File"
exiftool ${TARGET_FILE} >> ${FILE_EXIF}
cat -n ${FILE_EXIF} >> ${FILE_FULL}

# Run pescan
echo -e "==============================[ PESCAN ]================================\n" >> ${FILE_FULL}
echo "[+] Scanning File"
pescan ${TARGET_FILE} >> ${FILE_SCAN}
cat -n ${FILE_SCAN} >> ${FILE_FULL}

# Run pehash
echo -e "==============================[ PEHASH ]================================\n" >> ${FILE_FULL}
echo "[+] Finding Hashes"
pehash ${TARGET_FILE} >> ${FILE_HASH}
cat -n ${FILE_HASH} >> ${FILE_FULL}

# Run pestr
echo -e "==============================[ PESTR ]================================\n" >> ${FILE_FULL}
echo "[+] Pulling Strings"
pestr ${TARGET_FILE} >> ${FILE_STR}
cat -n ${FILE_STR} >> ${FILE_FULL}

# Run pepack
echo -e "==============================[ PEPACK ]================================\n" >> ${FILE_FULL}
echo "[+] Checking for Packers"
pepack ${TARGET_FILE} >> ${FILE_PACK}
cat -n ${FILE_PACK} >> ${FILE_FULL}

# Run yara index scan
echo -e "==============================[ YARA INDEX ]================================\n" >> ${FILE_FULL}
echo "[+] YARA Index Scan"
yara -w -s /usr/local/yara-rules/index.yar ${TARGET_FILE} >> ${FILE_YARA}
cat -n ${FILE_YARA} >> ${FILE_FULL}

# Run yara scan of URLs and IPs
echo -e "==============================[ YARA URL/IP ]================================\n" >> ${FILE_FULL}
echo "[+] YARA URL and IP Scan"
yara -w -s /usr/local/yara-rules/find_urls_ips.yar ${TARGET_FILE} >> ${FILE_URLS}
cat -n ${FILE_URLS} >> ${FILE_FULL}

# Run binwalk and pesec
echo -e "==============================[ BINWALK & PESEC ]================================\n" >> ${FILE_FULL}
echo "[+] Checking for Certificates"
binwalk ${TARGET_FILE} >> ${FILE_BIN}
cat -n ${FILE_BIN} >> ${FILE_FULL}
echo -e "-----------------------------------------------------------------------------" >> ${FILE_FULL}
pesec ${TARGET_FILE} >> ${FILE_PESEC}
cat -n ${FILE_PESEC} >> ${FILE_FULL}

# Final option
echo -e "\n==============================[ END ]================================\n" >> ${FILE_FULL}
echo -e "\n>>> Output files located in the (${MAIN_DIR}/${TARGET_SUBDIR}) directory <<<\n"

# Show results, can omit if you wish. Results will be saved in files
while true; do
	read -p "Do you want to view the full output now? (y/n) " yn
	case $yn in 
		[Yy]* ) code ${FILE_FULL}; break;;
		[Nn]* ) break;;
	esac
done
echo -e "Exiting now!\n"

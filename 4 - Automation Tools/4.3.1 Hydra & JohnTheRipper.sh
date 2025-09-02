#!/bin/bash
set -euo pipefail

# Title: Password Cracking Launcher
# Author: Lucio Rodrigues
# Description: Automates Hydra and John scans with selectable wordlists

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Check if tools exist
command -v hydra >/dev/null 2>&1 || { echo -e "${RED}[!] Hydra not installed. Exiting.${RESET}"; exit 1; }
command -v john  >/dev/null 2>&1 || { echo -e "${RED}[!] John the Ripper not installed. Exiting.${RESET}"; exit 1; }

# Define wordlist paths
COMMON="/usr/share/wordlists/rockyou.txt"
BIG="/usr/share/wordlists/dirb/big.txt"
SEC_LIST="/usr/share/wordlists/seclists/Passwords/Common-Credentials/best110.txt"
TOP_100="/usr/share/wordlists/seclists/Passwords/Common-Credentials/top-100.txt"
CUSTOM=""

# Output directories
HYDRA_DIR="scans/hydra"
JOHN_DIR="scans/john"
mkdir -p "$HYDRA_DIR" "$JOHN_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Banner
echo -e "${CYAN}======================================"
echo "       Password Cracking Launcher"
echo -e "======================================${RESET}"
echo ""
echo -e "${YELLOW}Select cracking tool:${RESET}"
echo "1) Hydra (Service Login Brute Force)"
echo "2) John the Ripper (Hash Cracker)"
read -p "Enter choice (1 or 2): " TOOL_TYPE

# Function to select wordlist
select_wordlist() {
  echo ""
  echo -e "${YELLOW}Select wordlist:${RESET}"
  echo "1) Basic (rockyou.txt)"
  echo "2) Deep (dirb/big.txt)"
  echo "3) Medium (seclists best110.txt)"
  echo "4) Fast (top-100.txt)"
  echo "5) Custom wordlist"
  read -p "Enter choice (1–5): " WL_CHOICE

  case $WL_CHOICE in
    1) WORDLIST=$COMMON; WL_NAME="rockyou";;
    2) WORDLIST=$BIG; WL_NAME="big";;
    3) WORDLIST=$SEC_LIST; WL_NAME="best110";;
    4) WORDLIST=$TOP_100; WL_NAME="top100";;
    5) 
      read -p "Enter full path to your custom wordlist: " CUSTOM
      if [ ! -f "$CUSTOM" ]; then
        echo -e "${RED}[!] Wordlist not found. Exiting.${RESET}"
        exit 1
      fi
      WORDLIST="$CUSTOM"
      WL_NAME="custom"
      ;;
    *) 
      echo -e "${RED}[!] Invalid option. Exiting.${RESET}"
      exit 1
      ;;
  esac
}

# Hydra Section
if [ "$TOOL_TYPE" == "1" ]; then
  echo ""
  echo -e "${CYAN}[HYDRA MODE SELECTED]${RESET}"
  select_wordlist

  read -p "Enter target IP or domain: " TARGET
  read -p "Enter login service (e.g. ssh, ftp, http-post-form): " SERVICE
  read -p "Enter port (press Enter to skip for default): " PORT
  read -p "Enter single username or path to username list: " USER_INPUT
  read -p "Enter extra Hydra options (or leave blank): " EXTRA_OPTS

  if [ -f "$USER_INPUT" ]; then
    USER_OPTION="-L $USER_INPUT"
  else
    USER_OPTION="-l $USER_INPUT"
  fi

  if [ -z "$PORT" ]; then
    PORT_OPTION=""
  else
    PORT_OPTION="-s $PORT"
  fi

  OUTPUT_FILE="$HYDRA_DIR/hydra_${SERVICE}_${TARGET}_${WL_NAME}_${TIMESTAMP}.txt"

  # Summary before execution
  echo ""
  echo -e "${CYAN}======================================"
  echo " Hydra Scan Summary"
  echo -e "======================================${RESET}"
  echo -e "${YELLOW}Target:     ${RESET}$TARGET"
  echo -e "${YELLOW}Service:    ${RESET}$SERVICE"
  echo -e "${YELLOW}Port:       ${RESET}${PORT:-default}"
  echo -e "${YELLOW}User input: ${RESET}$USER_INPUT"
  echo -e "${YELLOW}Wordlist:   ${RESET}$WL_NAME"
  echo -e "${YELLOW}Output:     ${RESET}$OUTPUT_FILE"
  echo -e "${YELLOW}Extra opts: ${RESET}${EXTRA_OPTS:-none}"
  echo -e "${CYAN}======================================${RESET}"
  read -p "Proceed? (y/n): " CONFIRM
  [[ "$CONFIRM" != "y" ]] && echo -e "${RED}Exiting.${RESET}" && exit 0

  hydra $PORT_OPTION $USER_OPTION -P "$WORDLIST" $EXTRA_OPTS "$TARGET" "$SERVICE" -o "$OUTPUT_FILE"

  echo ""
  echo -e "${GREEN}[+] Hydra scan complete. Output saved to '$OUTPUT_FILE'${RESET}"

# John Section
elif [ "$TOOL_TYPE" == "2" ]; then
  echo ""
  echo -e "${CYAN}[JOHN THE RIPPER MODE SELECTED]${RESET}"
  select_wordlist

  read -p "Enter path to hash file (e.g. hashes.txt): " HASHFILE
  if [ ! -f "$HASHFILE" ]; then
    echo -e "${RED}[!] Hash file not found. Exiting.${RESET}"
    exit 1
  fi

  echo ""
  echo -e "${YELLOW}Select hash format (examples: raw-md5, sha256crypt, NT, bcrypt)${RESET}"
  echo "Leave blank to let John auto-detect."
  read -p "Enter hash format: " HASH_FORMAT

  OUTPUT_FILE="$JOHN_DIR/john_${WL_NAME}_${TIMESTAMP}.txt"

  # Summary before execution
  echo ""
  echo -e "${CYAN}======================================"
  echo " John the Ripper Summary"
  echo -e "======================================${RESET}"
  echo -e "${YELLOW}Hash file:   ${RESET}$HASHFILE"
  echo -e "${YELLOW}Wordlist:    ${RESET}$WL_NAME"
  echo -e "${YELLOW}Hash format: ${RESET}${HASH_FORMAT:-auto}"
  echo -e "${YELLOW}Output:      ${RESET}$OUTPUT_FILE"
  echo -e "${CYAN}======================================${RESET}"
  read -p "Proceed? (y/n): " CONFIRM
  [[ "$CONFIRM" != "y" ]] && echo -e "${RED}Exiting.${RESET}" && exit 0

  if [ -z "$HASH_FORMAT" ]; then
    john --wordlist="$WORDLIST" "$HASHFILE"
  else
    john --format="$HASH_FORMAT" --wordlist="$WORDLIST" "$HASHFILE"
  fi

  # Save cracked results
  john --show "$HASHFILE" | tee "$OUTPUT_FILE"

  echo ""
  echo -e "${GREEN}[+] John the Ripper complete. Cracked hashes saved to '$OUTPUT_FILE'${RESET}"

else
  echo -e "${RED}[!] Invalid option selected. Exiting.${RESET}"
  exit 1
fi

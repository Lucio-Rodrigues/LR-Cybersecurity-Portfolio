#!/bin/bash

# Title: Gobuster Directory Scan Script
# Author: Lucio Rodrigues
# Description: Offers menu-driven Gobuster scans using curated wordlists

# Define wordlist paths
COMMON="/usr/share/wordlists/dirb/common.txt"
BIG="/usr/share/wordlists/dirb/big.txt"
RAFT_MED="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
RAFT_LARGE="/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"
CUSTOM="/path/to/your/custom.txt"  # Optional: update if needed

# Output directory
OUTPUT_DIR="scans/gobuster"
mkdir -p "$OUTPUT_DIR"

# Timestamp for filename
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Banner
echo "====================================="
echo "         Gobuster Scan Launcher"
echo "====================================="
echo ""
echo "Select scan type:"
echo "1) Basic Directory Scan (common.txt)"
echo "2) Deep Directory Scan (big.txt)"
echo "3) Medium Scan (directory-list-2.3-medium.txt)"
echo "4) Large Scan (directory-list-2.3-small.txt)"
echo "5) Custom Wordlist"
read -p "Enter choice (1-5): " SCAN_TYPE

# Prompt for target
read -p "Enter the target URL (e.g., http://example.com): " TARGET

# Assign wordlist based on choice
case $SCAN_TYPE in
  1)
    SCAN_NAME="Basic"
    WORDLIST=$COMMON
    ;;
  2)
    SCAN_NAME="Deep"
    WORDLIST=$BIG
    ;;
  3)
    SCAN_NAME="Medium"
    WORDLIST=$RAFT_MED
    ;;
  4)
    SCAN_NAME="Large"
    WORDLIST=$RAFT_LARGE
    ;;
  5)
    read -p "Enter full path to your custom wordlist: " CUSTOM
    if [ ! -f "$CUSTOM" ]; then
      echo "[!] Custom wordlist not found. Exiting."
      exit 1
    fi
    SCAN_NAME="Custom"
    WORDLIST="$CUSTOM"
    ;;
  *)
    echo "[!] Invalid selection. Exiting."
    exit 1
    ;;
esac

# Run gobuster scan
OUTPUT_FILE="$OUTPUT_DIR/gobuster_${SCAN_NAME}_${TIMESTAMP}.txt"
echo "[*] Running $SCAN_NAME scan against $TARGET"
echo "[*] Using wordlist: $WORDLIST"
echo ""

gobuster dir -u "$TARGET" -w "$WORDLIST" -o "$OUTPUT_FILE"

echo ""
echo "[+] Scan complete. Output saved to '$OUTPUT_FILE'"

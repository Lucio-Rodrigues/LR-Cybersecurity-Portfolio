#!/bin/bash

# Title: Nmap Scanning Menu
# Author: Lucio Rodrigues
# Description: Menu-driven Nmap scanner with 4 curated scan types.

# Output directory
OUTPUT_DIR="scans/nmap"
mkdir -p "$OUTPUT_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Prompt for target
echo "===================================="
echo "          Nmap Scanner"
echo "===================================="
read -p "Enter the target IP or hostname: " TARGET

# Menu
echo ""
echo "Select Nmap scan type:"
echo "1) Basic Port Scan (Fast)"
echo "2) Full Port Scan (All 65535 Ports)"
echo "3) Service & Version Detection"
echo "4) Aggressive Scan (OS, Traceroute, Scripts)"
read -p "Enter your choice (1-6): " CHOICE

# Handle user selection
case $CHOICE in
  1)
    echo "[*] Running fast basic port scan..."
    OUTPUT_FILE="$OUTPUT_DIR/nmap_basic_${TARGET}_${TIMESTAMP}.txt"
    CMD="nmap -T4 -F $TARGET -oN $OUTPUT_FILE"
    ;;
  2)
    echo "[*] Running full port scan (slow)..."
    OUTPUT_FILE="$OUTPUT_DIR/nmap_full_${TARGET}_${TIMESTAMP}.txt"
    CMD="nmap -p- -T5 $TARGET -oN $OUTPUT_FILE"
    ;;
  3)
    echo "[*] Running service/version detection..."
    OUTPUT_FILE="$OUTPUT_DIR/nmap_service_${TARGET}_${TIMESTAMP}.txt"
    CMD="nmap -sV -sC $TARGET -oN $OUTPUT_FILE"
    ;;
  4)
    echo "[*] Running aggressive scan..."
    OUTPUT_FILE="$OUTPUT_DIR/nmap_aggressive_${TARGET}_${TIMESTAMP}.txt"
    CMD="nmap -A $TARGET -oN $OUTPUT_FILE"
    ;;
  *)
    echo "[!] Invalid option. Exiting."
    exit 1
    ;;
esac

# Execute scan
echo ""
echo "[*] Executing: $CMD"
eval $CMD
echo ""
echo "[+] Scan complete. Output saved to $OUTPUT_FILE"

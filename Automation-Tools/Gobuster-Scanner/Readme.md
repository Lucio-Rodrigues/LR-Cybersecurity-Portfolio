# Gobuster Automation Tool

This is a Bash-based interactive script that automates directory brute-forcing using gobuster. Designed for both speed and flexibility, it offers a menu of curated wordlists and optional custom input, helping you uncover hidden web directories quickly during recon.

---

🎯 Purpose

To accelerate web enumeration workflows by simplifying common Gobuster directory scans. This tool eliminates the need to memorise paths or syntax, helping both newcomers and experienced pentesters stay efficient during assessments.

---

⚙️ Features

Built entirely in Bash

Interactive user prompts:
 - Target URL
 - Wordlist selection (5 options)

Predefined wordlists included:
 - common.txt
 - big.txt
 - directory-list-2.3-medium.txt
 - directory-list-2.3-small.txt
 - Option to use a custom wordlist

Scan output is saved with timestamps for traceability

Organized directory structure for results

---

🧪 Scan Options

Basic Directory Scan
  Uses `common.txt` for quick, high-probability directory discovery.

Deep Directory Scan
  Uses `big.txt` for broader brute-force coverage.

Medium Scan
  Uses `directory-list-2.3-medium.txt` from the DirBuster set.

Large Scan
  Uses `directory-list-2.3-small.txt` (don't get tricked by the name, larger than medium).

Custom Wordlist
  Allows you to input the full path to a personal or task-specific wordlist.

---

📸 Screenshots

<img width="500" height="289" alt="Screenshot 2025-08-24 at 10 52 22" src="https://github.com/user-attachments/assets/6e1f25c0-83d4-4a01-ad27-439cf9b4a136" />
<img width="591" height="458" alt="Screenshot 2025-08-24 at 10 53 03" src="https://github.com/user-attachments/assets/536233da-74bf-4e7f-8e36-978e9868e0b4" />
<img width="768" height="408" alt="Screenshot 2025-08-24 at 10 54 29" src="https://github.com/user-attachments/assets/a7adde1a-29cf-4001-9514-b99120035707" />
<img width="998" height="432" alt="Screenshot 2025-08-24 at 10 56 11" src="https://github.com/user-attachments/assets/1742829c-788f-487d-8d79-a336afdf1aa0" />


---

🚀 Example Usage

$ ./gobuster-scan.sh

=====================================
         Gobuster Scan Launcher
=====================================

Select scan type:
  1) Basic Directory Scan (common.txt)
  2) Deep Directory Scan (big.txt)
  3) Medium Scan (directory-list-2.3-medium.txt)
  4) Large Scan (directory-list-2.3-small.txt)
  5) Custom Wordlist
  Enter choice (1–5): 3

Enter the target URL (e.g., http://example.com): http://10.10.11.5

[*] Running Medium scan against http://10.10.11.5
[*] Using wordlist: /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

[+] Scan complete. Output saved to 'scans/gobuster/gobuster_Medium_2025-07-17_10-33-22.txt'

---

🧠 Why This Tool Matters

Directory discovery can reveal login panels, admin portals, APIs, and other crucial attack surfaces. This script ensures you can perform these scans quickly, consistently, and with cleanly saved results. It's perfect for CTFs, labs, or real-world pentests.

---

📎 Related MITRE ATT&CK Techniques

TA0043 – Reconnaissance
T1595 – Active Scanning
T1590 – Gather Victim Network Information
T1190 – Exploit Public-Facing Application
T1210 – Exploitation of Remote Services

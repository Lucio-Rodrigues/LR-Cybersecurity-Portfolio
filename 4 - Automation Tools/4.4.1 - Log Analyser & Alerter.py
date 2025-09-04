# Title: Log Analyser & Alerter (Python)
# Author: Lucio Rodrigues
# Description: A Python-based log analysis tool that detects brute force, invalid access, and DoS patterns with MITRE ATT&CK correlation.

import os
import re
from collections import Counter
from datetime import datetime
from getpass import getpass

# -----------------------------
# Detection Patterns (Regex)
# -----------------------------
# Each pattern must capture the *IP address* in group 1
PATTERNS = {
    "Failed Login": r"Failed password for .* from (\d+\.\d+\.\d+\.\d+)",
    "Invalid User": r"Invalid user .* from (\d+\.\d+\.\d+\.\d+)",
    # A generic access-line style hit counter (e.g., nginx/apache). Any line with "<ip> - -" will be counted.
    "Possible DoS": r"(\d+\.\d+\.\d+\.\d+)\s+-\s+-\s+.*"
}

# Default thresholds (user can accept or override via prompts if desired)
DEFAULT_ALERT_THRESHOLD = 5  # e.g., >=5 events from the same IP triggers ⚠️


# -----------------------------
# Core Functions
# -----------------------------

def parse_logs(log_file: str) -> list[str]:
    """Read the log file and return a list of lines."""
    try:
        with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
            return f.readlines()
    except FileNotFoundError:
        raise FileNotFoundError(f"Log file not found: {log_file}")


def analyse_logs(log_lines: list[str]) -> dict[str, list[str]]:
    """Apply regex patterns to log lines and collect matched IPs by category."""
    findings: dict[str, list[str]] = {category: [] for category in PATTERNS}

    for line in log_lines:
        for category, pattern in PATTERNS.items():
            m = re.search(pattern, line)
            if m:
                findings[category].append(m.group(1))

    return findings


def generate_report(findings: dict[str, list[str]], alert_threshold: int) -> str:
    """Create a human-readable summary report with alert flags."""
    lines: list[str] = []
    lines.append("==== Log Analysis Report ====")
    lines.append(f"Generated: {datetime.now().isoformat(timespec='seconds')}")
    lines.append("")

    for category, ips in findings.items():
        lines.append(f"{category}:")
        if not ips:
            lines.append("  (none)")
            lines.append("")
            continue
        counts = Counter(ips)
        for ip, count in counts.items():
            status = "⚠️ ALERT" if count >= alert_threshold else "OK"
            lines.append(f"  {ip}: {count} events ({status})")
        lines.append("")

    return "\n".join(lines).strip()


def save_report(report: str, directory: str = "reports") -> str:
    """Save the report to a timestamped file in /reports and return its path."""
    os.makedirs(directory, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    path = os.path.join(directory, f"report_{timestamp}.txt")
    with open(path, "w", encoding="utf-8") as f:
        f.write(report + "\n")
    return path


# -----------------------------
# Helpers (Interactive Prompts)
# -----------------------------

def prompt_path(prompt: str, default: str | None = None) -> str:
    """Prompt for a file path with optional default; reprompt until it exists."""
    while True:
        raw = input(f"{prompt}{f' [{default}]' if default else ''}: ").strip()
        path = raw or (default or "")
        if os.path.isfile(path):
            return path
        print("File not found. Please try again.")


def prompt_yes_no(prompt: str, default: bool = False) -> bool:
    """Yes/No prompt returning a boolean."""
    suffix = "Y/n" if default else "y/N"
    ans = input(f"{prompt} ({suffix}): ").strip().lower()
    if not ans:
        return default
    return ans in {"y", "yes"}


def prompt_int(prompt: str, default: int) -> int:
    raw = input(f"{prompt} [{default}]: ").strip()
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        print("Invalid number. Using default.")
        return default


# -----------------------------
# Main (Interactive Flow)
# -----------------------------
if __name__ == "__main__":
    print("\n=== Log Analyser (Interactive) ===\n")

    # 1) Log file selection
    log_file = prompt_path("Enter path to log file", default="sample_logs.txt")

    # 2) Threshold override (optional)
    alert_threshold = prompt_int("Set alert threshold (events per IP)", DEFAULT_ALERT_THRESHOLD)

    # 3) Parse, analyse, report
    try:
        lines = parse_logs(log_file)
    except FileNotFoundError as e:
        print(f"❌ {e}")
        raise SystemExit(1)

    findings = analyse_logs(lines)
    report = generate_report(findings, alert_threshold)

    print("\n" + report + "\n")

    # 4) Optional: save report
    if prompt_yes_no("Save report to /reports?", default=True):
        path = save_report(report)
        print(f"💾 Saved: {path}")

    print("\nDone.\n")

#!/bin/bash

# Using ANSI escape codes that respect terminal colors
# These will automatically use your Catppuccin colors
BOLD='\033[1m'
RESET='\033[0m'
# Base colors (will use Catppuccin equivalents)
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
# Bright variants
BRIGHT_BLACK='\033[90m'
BRIGHT_RED='\033[91m'
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'
BRIGHT_MAGENTA='\033[95m'
BRIGHT_CYAN='\033[96m'
BRIGHT_WHITE='\033[97m'

# ASCII Art using Catppuccin colors
echo -e "${BLUE}${BOLD}"
cat << "EOF"
    ____  _____    ____  __  ___
   / __ \/ ___/   / __ \/  |/  /
  / / / /\__ \   / / / / /|_/ / 
 / /_/ /___/ /  / /_/ / /  / /  
/_____//____/  /_____/_/  /_/   
EOF
echo -e "${RESET}"

# System Information with Catppuccin colors
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${BRIGHT_GREEN}Welcome, ${BRIGHT_CYAN}$USER${RESET}!"
echo -e "${GREEN}Hostname:${RESET} $(hostname)"
echo -e "${GREEN}OS:${RESET} $(uname -s)"
echo -e "${GREEN}Kernel:${RESET} $(uname -r)"
echo -e "${GREEN}Uptime:${RESET} $(uptime -p)"
echo -e "${GREEN}Memory Usage:${RESET} $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo -e "${GREEN}Disk Usage:${RESET} $(df -h / | awk 'NR==2 {print $3 "/" $2}')"
echo -e "${GREEN}CPU Load:${RESET} $(uptime | awk -F'load average:' '{print $2}')"
echo -e "${MAGENTA}======================================${RESET}"

# Date and Time
echo -e "${YELLOW}$(date '+%A, %B %d, %Y %T')${RESET}"
echo ""

# Optional: Add custom message or quote
echo -e "${CYAN} Stay hungry! 💻${RESET}"

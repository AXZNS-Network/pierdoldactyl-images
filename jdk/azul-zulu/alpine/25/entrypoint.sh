#!/bin/bash
cd /home/container || exit 1

# ============================================================================
# AXZNS Advanced Container Startup Script (Fixed)
# ============================================================================

# Color Configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET_COLOR='\033[0m'

# Advanced Functions
show_loading_animation() {
    local message="$1"
    local duration="${2:-3}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local end_time=$((SECONDS + duration))

    while [ $SECONDS -lt $end_time ]; do
        for frame in "${frames[@]}"; do
            printf "\r${CYAN}${frame}${RESET_COLOR} ${message}"
            sleep 0.1
        done
    done
    printf "\r${GREEN}✓${RESET_COLOR} ${message}${RESET_COLOR}\n"
}

get_system_info() {
    local mem_total mem_available mem_used cpu_count load_avg disk_usage disk_free

    # Memory info
    mem_total=$(awk '/MemTotal:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)
    mem_available=$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)

    if [[ -n "$mem_total" && -n "$mem_available" ]]; then
        mem_used=$((mem_total - mem_available))
    else
        mem_total=0
        mem_available=0
        mem_used=0
    fi

    # CPU info
    cpu_count=$(nproc 2>/dev/null || echo 0)
    load_avg=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//' || echo 0)

    # Disk info
    disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "0%")
    disk_free=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")

    echo "${mem_used}MB/${mem_total}MB|${cpu_count}|${load_avg}|${disk_usage}|${disk_free}"
}

create_progress_bar() {
    local progress=$1
    local width=40
    local filled=$((progress * width / 100))
    local empty=$((width - filled))

    printf "["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "] %d%%" $progress
}

check_java_performance() {
    if command -v java >/dev/null 2>&1; then
        local java_version java_vendor
        java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        java_vendor=$(java -version 2>&1 | grep -i "openjdk\|oracle\|azul" | head -n1)
        echo "${java_version:-Unknown}|${java_vendor:-Unknown}"
    else
        echo "Not Available|N/A"
    fi
}

validate_environment() {
    local errors=0
    local warnings=0

    # Check critical directories
    for dir in "/home/container" "/tmp"; do
        if [[ ! -d "$dir" ]]; then
            echo -e "${RED}✗ Missing directory: $dir${RESET_COLOR}"
            ((errors++))
        fi
    done

    # Check disk space
    local disk_usage_num
    disk_usage_num=$(df / 2>/dev/null | awk 'NR==2 {print substr($5,1,length($5)-1)}')
    disk_usage_num=${disk_usage_num:-0}

    if [[ $disk_usage_num -gt 90 ]]; then
        echo -e "${RED}✗ Critical: Disk usage above 90%${RESET_COLOR}"
        ((errors++))
    elif [[ $disk_usage_num -gt 80 ]]; then
        echo -e "${YELLOW}⚠ Warning: Disk usage above 80%${RESET_COLOR}"
        ((warnings++))
    fi

    # Check memory
    local mem_info mem_used mem_total mem_percent
    mem_info=$(get_system_info)
    mem_used=$(echo "$mem_info" | cut -d'|' -f1 | sed 's/MB.*//' || echo 0)
    mem_total=$(echo "$mem_info" | cut -d'|' -f1 | sed 's/.*\///' | sed 's/MB//' || echo 0)

    if [[ $mem_total -gt 0 && $mem_used -ge 0 ]]; then
        mem_percent=$((mem_used * 100 / mem_total))
        if [[ $mem_percent -gt 90 ]]; then
            echo -e "${RED}✗ Critical: Memory usage above 90%${RESET_COLOR}"
            ((errors++))
        fi
    fi

    echo "$errors|$warnings"
}

# Initialize system variables
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || echo "Unknown")
export INTERNAL_IP

CONTAINER_ID=$(hostname 2>/dev/null || echo "Unknown")
UPTIME=$(uptime -p 2>/dev/null || echo "Unknown")
SYSTEM_INFO=$(get_system_info)
JAVA_INFO=$(check_java_performance)
VALIDATION_RESULT=$(validate_environment)

# Extract system metrics
MEM_INFO=$(echo "$SYSTEM_INFO" | cut -d'|' -f1)
CPU_COUNT=$(echo "$SYSTEM_INFO" | cut -d'|' -f2)
LOAD_AVG=$(echo "$SYSTEM_INFO" | cut -d'|' -f3)
DISK_USAGE=$(echo "$SYSTEM_INFO" | cut -d'|' -f4)
DISK_FREE=$(echo "$SYSTEM_INFO" | cut -d'|' -f5)

JAVA_VERSION=$(echo "$JAVA_INFO" | cut -d'|' -f1)
JAVA_VENDOR=$(echo "$JAVA_INFO" | cut -d'|' -f2)

ERRORS=$(echo "$VALIDATION_RESULT" | cut -d'|' -f1)
WARNINGS=$(echo "$VALIDATION_RESULT" | cut -d'|' -f2)

# Loading animation
show_loading_animation "Initializing AXZNS Container..." 2

clear

# ============================================================================
# MAIN BANNER DISPLAY
# ============================================================================

echo -e "${BLUE}┌──────────────────────────────────────────────────────────────┐${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${MAGENTA}${BOLD} █████╗ ██╗  ██╗███████╗███╗   ██╗███████╗${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${MAGENTA}${BOLD}██╔══██╗╚██╗██╔╝╚══███╔╝████╗  ██║██╔════╝${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${MAGENTA}${BOLD}███████║ ╚███╔╝  ███╔╝ ██╔██╗ ██║███████╗${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${MAGENTA}${BOLD}██╔══██║ ██╔██╗ ███╔╝  ██║╚██╗██║╚════██║${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${MAGENTA}${BOLD}██║  ██║██╔╝ ██╗███████╗██║ ╚████║███████║${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${MAGENTA}${BOLD}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}├──────────────────────────────────────────────────────────────┤${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${CYAN}${BOLD}Advanced Container Management System${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${WHITE}Container ID: ${YELLOW}${CONTAINER_ID}${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${WHITE}Network IP: ${YELLOW}${INTERNAL_IP}${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}│${RESET_COLOR} ${WHITE}Uptime: ${GREEN}${UPTIME}${RESET_COLOR} ${BLUE}│${RESET_COLOR}"
echo -e "${BLUE}└──────────────────────────────────────────────────────────────┘${RESET_COLOR}"

# ============================================================================
# SYSTEM INFORMATION PANEL
# ============================================================================

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET_COLOR}"
echo -e "${CYAN}║ ${WHITE}${BOLD}SYSTEM INFORMATION${RESET_COLOR} ${CYAN}║${RESET_COLOR}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET_COLOR}"
echo -e "${CYAN}║${RESET_COLOR} ${WHITE}Memory Usage: ${GREEN}${MEM_INFO}${RESET_COLOR} ${CYAN}║${RESET_COLOR}"
echo -e "${CYAN}║${RESET_COLOR} ${WHITE}CPU Cores: ${GREEN}${CPU_COUNT}${RESET_COLOR} ${WHITE}Load Avg: ${GREEN}${LOAD_AVG}${RESET_COLOR} ${CYAN}║${RESET_COLOR}"
echo -e "${CYAN}║${RESET_COLOR} ${WHITE}Disk Usage: ${GREEN}${DISK_USAGE}${RESET_COLOR} ${WHITE}Available: ${GREEN}${DISK_FREE}${RESET_COLOR} ${CYAN}║${RESET_COLOR}"
echo -e "${CYAN}║${RESET_COLOR} ${WHITE}Java Version: ${GREEN}${JAVA_VERSION}${RESET_COLOR} ${CYAN}║${RESET_COLOR}"
echo -e "${CYAN}║${RESET_COLOR} ${WHITE}Java Vendor: ${GREEN}${JAVA_VENDOR}${RESET_COLOR} ${CYAN}║${RESET_COLOR}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET_COLOR}"

# ============================================================================
# HEALTH CHECK PANEL
# ============================================================================

echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${RESET_COLOR}"
echo -e "${YELLOW}║ ${WHITE}${BOLD}HEALTH CHECK STATUS${RESET_COLOR} ${YELLOW}║${RESET_COLOR}"
echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${RESET_COLOR}"

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${YELLOW}║${RESET_COLOR} ${GREEN}✓ All systems operational${RESET_COLOR} ${YELLOW}║${RESET_COLOR}"
else
    echo -e "${YELLOW}║${RESET_COLOR} ${RED}✗ Issues detected: ${ERRORS} errors, ${WARNINGS} warnings${RESET_COLOR} ${YELLOW}║${RESET_COLOR}"
fi

# Progress bar for system health
health_score=$((100 - (ERRORS * 30) - (WARNINGS * 10)))
[[ $health_score -lt 0 ]] && health_score=0

echo -e "${YELLOW}║${RESET_COLOR} ${WHITE}System Health: $(create_progress_bar $health_score)${RESET_COLOR} ${YELLOW}║${RESET_COLOR}"
echo -e "${YELLOW}║${RESET_COLOR} ${WHITE}Date/Time: ${GREEN}$(date +"%Y-%m-%d %H:%M:%S %Z")${RESET_COLOR} ${YELLOW}║${RESET_COLOR}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${RESET_COLOR}"

# ============================================================================
# STARTUP COMMAND SECTION
# ============================================================================

echo ""
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════╗${RESET_COLOR}"
echo -e "${MAGENTA}║ ${WHITE}${BOLD}STARTUP CONFIGURATION${RESET_COLOR} ${MAGENTA}║${RESET_COLOR}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${RESET_COLOR}"

# Process startup variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

echo -e "${WHITE}Command: ${CYAN}${MODIFIED_STARTUP}${RESET_COLOR}"
echo -e "${WHITE}Working Directory: ${CYAN}$(pwd)${RESET_COLOR}"

USER_NAME=$(whoami 2>/dev/null || echo "user-$(id -u)")
echo -e "${WHITE}User: ${CYAN}${USER_NAME} (UID: $(id -u))${RESET_COLOR}"

# Environment variables display
echo ""
echo -e "${GRAY}${DIM}Key Environment Variables:${RESET_COLOR}"
env | grep -E "^(JAVA|PATH|HOME|USER)" | head -5 | while read -r line; do
    echo -e "${GRAY}  $line${RESET_COLOR}"
done

# ============================================================================
# SERVER START SECTION
# ============================================================================

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${RESET_COLOR}"
echo -e "${GREEN}║ ${WHITE}${BOLD}🚀 LAUNCHING APPLICATION SERVER${RESET_COLOR} ${GREEN}║${RESET_COLOR}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${RESET_COLOR}"

# Pre-launch checks
show_loading_animation "Performing pre-flight checks..." 1
show_loading_animation "Validating configuration..." 1
show_loading_animation "Initializing runtime environment..." 1

echo ""
echo -e "${WHITE}${BOLD}═══════════════════════ ${GREEN}SERVER OUTPUT${WHITE} ═══════════════════════${RESET_COLOR}"
echo ""

# Log startup information to file
cat >> /tmp/axzns-startup.log << EOF
[$(date)] AXZNS Container Started
Container ID: ${CONTAINER_ID}
IP Address: ${INTERNAL_IP}
System Info: ${SYSTEM_INFO}
Java Info: ${JAVA_INFO}
Startup Command: ${MODIFIED_STARTUP}
Working Directory: $(pwd)
User: $(whoami 2>/dev/null || echo "user-$(id -u)") (UID: $(id -u))
EOF

# Execute the main startup command
# shellcheck disable=SC2086
eval ${MODIFIED_STARTUP}

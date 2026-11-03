#!/bin/bash
cd /home/container || exit 1

# Banner
printf '\033[1;36m'
cat <<'EOF'
 _  __ ____   ____ _   _
| |/ /|  _ \ / ___| \ | |
| ' / | |_) | |   |  \| |
| . \ |  _ <| |___| |\  |
|_|\_\|_| \_\\____|_| \_|

 KRCN Services, spol. s r.o.
EOF
printf '\033[0m\n'

# Interná IP (Pterodactyl ju očakáva v INTERNAL_IP)
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Premenné zo startup príkazu: {{VAR}} -> ${VAR}
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Výpis príkazu a spustenie
printf '\033[1;33mcontainer@krcn~ \033[0m%s\n' "$(eval echo "${MODIFIED_STARTUP}")"

# shellcheck disable=SC2086
exec bash -c "${MODIFIED_STARTUP}"
#!/bin/env bash

show_title() {
    clear
    cat <<"EOL"
                                            
  _  _ _ _____            _    __  __
 | || (_)_   _| _ __ _ __| |___\ \/ /
 | __ | | | || '_/ _` / _` / -_)>  < 
 |_||_|_| |_||_| \__,_\__,_\___/_/\_\
                                     

EOL
}

function run_with_sudo() {
  for func_name in "$@"; do
    sudo bash -c "$(declare -f "$func_name"); $func_name"
  done
}

option_install_goaccess() {
    echo "========= INSTALL GOACCESS ============"

    source /etc/os-release
    case "$ID" in
        rhel)
            subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
            yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
            ;;
        almalinux)
            ;;
    esac

    yum install -y goaccess
    mkdir -p /var/www/goaccess
    chcon -R -t httpd_sys_content_t /var/www/goaccess
    cat <<'EOF' > /usr/lib/systemd/system/goaccess.service
[Unit]
Description=GoAccess real-time web log analysis
After=network-online.targe--no-pager t
Wants=network-online.target

[Service]
Type=simple
PIDFile=/var/run/goaccess.pid
ExecStart=/usr/bin/goaccess --real-time-html --ws-url=ws://moni.hitradex.local:80/ws -o /var/www/goaccess/index.html --port=7890 --config-file=/etc/goaccess/goaccess.conf -g --origin=http://moni.hitradex.local
ExecStop=/bin/kill -9 ${MAINPID}
WorkingDirectory=/tmp

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl start goaccess
    systemctl enable goaccess

    echo "complete successfully"
}

option_update_goaccess_config() {
    echo "========= UPDATE GOACCESS CONFIG ============"

    systemctl stop goaccess
    cat <<'EOF' > /etc/goaccess/goaccess.conf
### HITRADEX ###
# NGINX's log formats below.
log-file /var/log/nginx/hitradex-access.log
log-format COMBINED
time-format %H:%M:%S
date-format %d/%b/%Y
# Match with nginx.conf
log-format %h - %e %^[%d:%t %^] "%r" %s %b "%R" "%u" "%^" %T "%v" "%^" "%^"
# Prompt log/date configuration window on program start.
config-dialog false
# Color highlight active panel.
hl-header true
# Ignore request's query string.
no-query-string true
EOF
    systemctl start goaccess
    systemctl --no-pager status goaccess
    
    echo "complete successfully"
}

option_uninstall_goaccess() {
    echo "========= UNINSTALL GOACCESS ============"
    systemctl stop goaccess
    systemctl disable goaccess
    yum remove -y goaccess
    rm -rf /etc/goaccess
    rm -f /usr/lib/systemd/system/goaccess.service
    systemctl daemon-reload
    rm -rf /var/www/goaccess
    echo "complete successfully"
}

option_exit() {
    echo "========= EXIT ============"
    exit 0
}

clear
# Menu loop
while true; do
  show_title
  echo "Please select an option:"
  echo "1. Install Goaccess"
  echo "2. Update Goaccess Configs"
  echo "3. Unintall Goaccess"
  echo "4. EXIT"
  
  read -p "Enter your choice: " choice
  
  case $choice in
    1) run_with_sudo option_install_goaccess option_update_goaccess_config ;;
    2) run_with_sudo option_update_goaccess_config ;;
    3) run_with_sudo option_uninstall_goaccess ;;
    4) option_exit;;
    *) echo "Invalid option. Please try again." ;;
  esac
  read -p "<Press any key to continue> "
done

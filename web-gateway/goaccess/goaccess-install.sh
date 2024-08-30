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
  sudo bash -c "$(declare -f "$1"); $1"
}

option_install_goaccess() {
    echo "========= INSTALL GOACCESS ============"

    subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    yum install -y goaccess
    mkdir -p /var/www/goaccess
    chcon -R -t httpd_sys_content_t /var/www/goaccess
    cp ./goaccess.conf /etc/goaccess/
    cp ./goaccess.service /usr/lib/systemd/system/
    systemctl daemon-reload
    systemctl start goaccess
    systemctl enable goaccess

    echo "complete successfully"
}

option_update_goaccess_config() {
    echo "========= UPDATE GOACCESS CONFIG ============"

    systemctl stop goaccess
    cp ./goaccess.conf /etc/goaccess/
    systemctl start goaccess
    systemctl status goaccess
    
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
show_title
# Menu loop
while true; do
  echo "Please select an option:"
  echo "1. Install Nginx"
  echo "2. Update Nginx Configs"
  echo "3. Unintall Nginx"
  echo "4. EXIT"
  
  read -p "Enter your choice: " choice
  
  case $choice in
    1) run_with_sudo option_install_goaccess;;
    2) run_with_sudo option_update_goaccess_config ;;
    3) run_with_sudo option_uninstall_goaccess ;;
    4) option_exit;;
    *) echo "Invalid option. Please try again." ;;
  esac
done

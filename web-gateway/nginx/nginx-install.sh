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

option_install_nginx() {
    echo "========= INSTALL NGINX ============"
    # Check the user's response
    read -p "Are you sure you want to proceed? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Cancelled!"
        return
    fi


    yum update
    yum install -y yum-utils

    cat <<EOL > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOL

    yum-config-manager --enable nginx-stable
    #yum update
    yum install -y nginx

    # Linux SE
    setsebool -P httpd_can_network_connect 1

    # Firewalld
    echo "Verify firewalld"
    firewall-cmd --get-active-zones
    firewall-cmd --permanent --zone=public --add-service=http
    firewall-cmd --permanent --zone=public --add-service=https
    firewall-cmd --reload
    firewall-cmd --list-all

    systemctl start nginx
    systemctl enable nginx

    echo "complete successfully"
}

option_update_nginx_config() {
    echo "========= UPDATE NGINX CONFIG ============"
    # Check the user's response
    read -p "Are you sure you want to proceed? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Cancelled!"
        return
    fi

    cp nginx.conf /etc/nginx/
    mkdir -p /etc/nginx/cert
    cp ./cert/* /etc/nginx/cert
    source ./env.sh
    cp ./conf.d/default.conf /etc/nginx/conf.d/
    cp ./conf.d/monitor.conf /etc/nginx/conf.d/
    #cp ./conf.d/hitradex.conf /etc/nginx/conf.d/
    envsubst \
    ' ${SERVER_NAMES} ${BACKEND_SERVERS} ${FRONTEND_SERVERS} ${FILE_CERT_CRT} ${FILE_CERT_KEY} ${BACKEND_SCHEME} ${FRONTEND_SCHEME} ' \
    < ./conf.d/hitradex.template.conf > /etc/nginx/conf.d/hitradex.conf

    nginx -t
    if [ $? != 0 ];
    then
      echo "Pease verify the conf files"
      return
    fi
    echo "Nginx reload config files"
    nginx -s reload

    echo "complete successfully"
}

option_uninstall_nginx() {
    echo "========= UNINSTALL NGINX ============"
    # Check the user's response
    read -p "Are you sure you want to proceed? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Cancelled!"
        return
    fi

    systemctl disable nginx
    systemctl stop nginx
    yum remove -y nginx
    rm -rf /var/log/nginx
    rm -rf /var/cache/nginx
    rm -rf /etc/nginx

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
    1) run_with_sudo option_install_nginx ;;
    2) run_with_sudo option_update_nginx_config ;;
    3) run_with_sudo option_uninstall_nginx ;;
    4) option_exit;;
    *) echo "Invalid option. Please try again." ;;
  esac
done

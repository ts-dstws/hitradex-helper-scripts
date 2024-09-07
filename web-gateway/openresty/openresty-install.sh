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

option_install_openresty() {
    echo "========= INSTALL OPENRESTY ============"
    # Check the user's response
    read -p "Are you sure you want to proceed? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Cancelled!"
        return
    fi


    yum update
    yum install -y yum-utils

    source /etc/os-release
    case "$ID" in
        rhel)
            wget https://openresty.org/package/rhel/openresty.repo
            sudo mv openresty.repo /etc/yum.repos.d/openresty.repo
            ;;
        almalinux)
            wget https://openresty.org/package/centos/openresty.repo
            mv openresty.repo /etc/yum.repos.d/openresty.repo
            ;;
    esac

    yum update
    yum install -y openresty

    # Linux SE
    setsebool -P httpd_can_network_connect 1

    # Firewalld
    echo "Verify firewalld"
    firewall-cmd --get-active-zones
    firewall-cmd --permanent --zone=public --add-service=http
    firewall-cmd --permanent --zone=public --add-service=https
    firewall-cmd --reload
    firewall-cmd --list-all

    systemctl start openresty
    systemctl enable openresty

    echo "complete successfully"
}

option_update_openresty_config() {
    echo "========= UPDATE OPENRESTY CONFIG ============"
    # Check the user's response
    read -p "Are you sure you want to proceed? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Cancelled!"
        return
    fi

    mkdir -p /var/log/nginx

    bash openresty-genconf.sh
    mkdir -p /usr/local/openresty/nginx/conf/conf.d
    cp ./genconf.d/nginx.conf /usr/local/openresty/nginx/conf/
    cp ./genconf.d/conf.d/*.conf /usr/local/openresty/nginx/conf/conf.d/
    cp ./genconf.d/conf.d/*.lua /usr/local/openresty/nginx/conf/conf.d/

    mkdir -p /usr/local/openresty/nginx/conf/cert
    cp ./vhost/*.key /usr/local/openresty/nginx/conf/cert/
    cp ./vhost/*.crt /usr/local/openresty/nginx/conf/cert/

    openresty -t
    if [ $? != 0 ];
    then
      echo "Pease verify the conf files"
      return
    fi
    echo "Nginx reload config files"
    openresty -s reload

    echo "complete successfully"
}

option_uninstall_openresty() {
    echo "========= UNINSTALL OPENRESTY ============"
    # Check the user's response
    read -p "Are you sure you want to proceed? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Cancelled!"
        return
    fi

    systemctl disable openresty
    systemctl stop openresty
    yum remove -y openresry
    rm -rf /user/local/openresty
    rm -rf /var/log/nginx

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
  echo "1. Install Openresty"
  echo "2. Update Openresty Configs"
  echo "3. Unintall Openresty"
  echo "4. EXIT"
  
  read -p "Enter your choice: " choice
  
  case $choice in
    1) run_with_sudo option_install_openresty;;
    2) run_with_sudo option_update_openresty_config ;;
    3) run_with_sudo option_uninstall_openresty;;
    4) option_exit;;
    *) echo "Invalid option. Please try again." ;;
  esac
  read -p "<Press any key to continue> "
done

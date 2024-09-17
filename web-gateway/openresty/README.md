# hitradex-helper-scripts
HiTradeX Helper Scripts

## Web-Gateway Installer
- Download scripts:
  ```shell
  $ wget -q https://github.com/ts-dstws/hitradex-helper-scripts/archive/refs/heads/main.zip && unzip main.zip && rm -f main.zip
  ```

## Helper Tools
- Install Openresty
  ```shell
  $ cd hitradex-helper-scripts-main/web-gateway/openresty
  $ bash openresty-install.sh

     _  _ _ _____            _    __  __
    | || (_)_   _| _ __ _ __| |___\ \/ /
    | __ | | | || '_/ _` / _` / -_)>  <
    |_||_|_| |_||_| \__,_\__,_\___/_/\_\


    Please select an option:
    1. Install Openresty
    2. Update Openresty Configs
    3. Unintall Openresty
    4. EXIT
    Enter your choice: 1 < Enter >
  ```

- Modify configuration, edit files in directory vhost
  ```shell
    $ cd vhost/
    $ ls
    hitradex.com.env  hitradex.com.crt  hitradex.com.key

    $ mv hitradex.com.env hitradex.yourdomain.com.env
    $ mv hitradex.com.crt hitradex.yourdomain.com.crt
    $ mv hitradex.com.key hitradex.yourdomain.com.key

    $ vi hitradex.yourdomain.com.env
    ... Edit Server Names and IPs

    export SERVER_NAME="hitradex.youdomain.com" # Domain Name
    export SERVER_NAME_EXT="10.10.10.10 123.123.123.123" # IP Addresses of webgateway "Private-IP Public-IP"
    ...
    BACKEND_SERVERS="
        server 10.20.30.40:8080;
        server 10.20.30.41:8080;
    "; export BACKEND_SERVERS=$BACKEND_SERVERS # List of EGW Servers
    FRONTEND_SERVERS="
        server 10.20.30.40:8080;
        server 10.20.30.41:8080;
    "; export FRONTEND_SERVERS=$FRONTEND_SERVERS # List of EGW Frontend Servers
    ...
    ```

- Update configuration
  ```bash
  $ bash openresty-install.sh

     _  _ _ _____            _    __  __
    | || (_)_   _| _ __ _ __| |___\ \/ /
    | __ | | | || '_/ _` / _` / -_)>  <
    |_||_|_| |_||_| \__,_\__,_\___/_/\_\


    Please select an option:
    1. Install Openresty
    2. Update Openresty Configs
    3. Unintall Openresty
    4. EXIT
    Enter your choice: 2 < Enter >
 
  ```
# hitradex-helper-scripts
HiTradeX Helper Scripts

## Web-Gateway Installer
- Download scripts:
  ```bash
  wget -q https://github.com/ts-dstws/hitradex-helper-scripts/archive/refs/heads/main.zip && unzip main.zip && rm -f main.zip
  ```

## Helper Tools
- Openresty
  ```
  cd web-gateway/openresty/
  bash openresty-install.sh
  ```
- Goaccess
  ```
  cd web-gateway/goaccess/
  bash goaccess-install.sh
  ```
  Or
  ```bash
  bash -c "$(wget -qLO - https://raw.githubusercontent.com/ts-dstws/hitradex-helper-scripts/main/web-gateway/goaccess/goaccess-install.sh)"
  ```
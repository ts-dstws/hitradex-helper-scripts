# hitradex-helper-scripts
HiTradeX Helper Scripts

## Web-Gateway Installer
### Download scripts:
  ```shell
  $ wget -q https://github.com/ts-dstws/hitradex-helper-scripts/archive/refs/heads/main.zip && unzip main.zip && rm -f main.zip
  ```

## Helper Tools
### Openresty
  [README](web-gateway/openresty/README.md)
### Goaccess
  ```shell
  $ cd web-gateway/goaccess/
  $ bash goaccess-install.sh
  ```
  Or
  ```shell
  $ bash -c "$(wget -qLO - https://raw.githubusercontent.com/ts-dstws/hitradex-helper-scripts/main/web-gateway/goaccess/goaccess-install.sh)"
  ```
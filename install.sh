#!/bin/bash

# Install everything I need on WSL

set -ex

# NodeJS needs to add a package source, do this first
# Go check https://deb.nodesource.com/ to verify version
curl -fsSL https://deb.nodesource.com/setup_26.x | sudo bash -

# Update system
sudo apt-get update
sudo apt-get -y dist-upgrade

# Install my tools
sudo apt-get install -y \
    vim screen shellcheck sl \
    build-essential net-tools \
    clang clang-tidy clang-tools \
    nodejs \
    flake8 pylint python-is-python3 python3-pip python3-venv \
    git-lfs \
    mysql-server nginx nginx-core \
    openocd \
    texlive ghostscript psutils \
    udev

# Install web server (requires multiple steps)
sudo apt-get install -y php-fpm php-mysql
sudo apt-get install -y phpmyadmin
# TODO PHPStan/Psalm/PHPMD

# Javascript linter
# Not working, issue with dependencies nodejs
#sudo apt-get install -y eslint

# Fix locale
#sudo locale-gen "en_US.UTF-8"
#sudo dpkg-reconfigure locales

# cifs-utils?



# CONFIG
[ -d ~/.wash ] || git clone https://github.com/xonqnopp/vash.git ~/.wash
[ -L ~/.vimrc ] || ln -s ~/.wash/.vimrc ~/.vimrc
sudo pip install venv_autouse --break-system-packages



# PRIVATE
mkdir -p .private
(
    cd .private
    [ -d flying ] || git clone https://github.com/xonqnopp/flying.git
    [ -d recettes ] || git clone https://github.com/xonqnopp/recettes.git

    cd recettes
    [ -d .venv ] || python -m venv .venv
    ./.venv/bin/python -m pip install -r requirements.txt

    if [ ! -d /var/www/web-xonqnopp ]; then
        git clone https://github.com/xonqnopp/web-xonqnopp.git
        sudo mv web-xonqnopp /var/www/web-xonqnopp
        sudo chown -R apollo:www-data /var/www/web-xonqnopp
        sudo chmod -R a+rw /var/www/web-xonqnopp
        sudo usermod -a -G www-data apollo
    fi
)
[ ! -f .private/.gitxn ] && echo "MISSING credentials for github"
[ -L ~/.private/web-xonqnopp ] || sudo ln -s /var/www/web-xonqnopp ~/.private/web-xonqnopp
[ ! -f .private/web-xonqnopp/yptok ] && echo "MISSING credentials for web-xonqnopp"


# Copilot CLI
sudo npm install -g @github/copilot
# open it and log in






#sudo ln -s /usr/share/phpmyadmin /var/www/web-xonqnopp/

# nginx
phpversion=$(dpkg --get-selections | grep '^php[0-9]\.' | grep fpm | cut -f1 | cut -dp -f3 | cut -d- -f1)
read -rp "Set PHP version to $phpversion in nginx config. Press enter to edit the file..." foo
vim web/config

echo "Tell WSL to not automatically generate hosts, add:"
echo "[network]"
echo "generateHosts = false"
# shellcheck disable=SC2034
read -rp "to /etc/wsl.conf. Press enter to edit the file..." foo
sudo vim /etc/wsl.conf

echo "127.0.0.1	xn.local" | sudo tee -a /etc/hosts

sudo cp web/info.php /var/www/html/  # if you want to check, be sure to enable PHP in default config
avail="/etc/nginx/sites-available/xonqnopp"
enabl="/etc/nginx/sites-enabled/xonqnopp"
sudo cp web/config "$avail"
sudo rm -f "$enabl"
sudo ln -s "$avail" "$enabl"
sudo nginx -t
sudo systemctl restart nginx

# mysql
# shellcheck disable=SC2024
sudo mysql < web/dump.sql
# shellcheck disable=SC2024
sudo mysql < web/user.sql
# sudo mysqldump --all-databases > web/dump.sql

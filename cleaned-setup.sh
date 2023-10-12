#! /bin/bash
command_exists() {
    command -v "$1" >/dev/null 2>&1;
}

sudo apt update -y
 
if ! command_exists apache2; then
    sudo add-apt-repository -y ppa:ondrej/apache2
    sudo apt update
fi

sudo apt install -y --no-install-recommends libmagickwand-dev apache2 libapache2-mod-php imagemagick ghostscript-x supervisor software-properties-common unzip zip redis-server
git clone https://github.com/ap-coder/php-switch-scripts.git
bash ./php-switch-scripts/setup.sh 
bash ./php-switch-scripts/switch-to-php-8.1.sh
sudo a2enmod rewrite

if ! command_exists composer; then
    wget -O composer-setup.php https://getcomposer.org/installer
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    sudo chmod +x /usr/local/bin/composer
    sudo composer self-update
fi

mkdir -p ~/www/html/public
ssh-keygen -t rsa -b 4096 -C "production@tyrant" -N "" -f ~/.ssh/id_rsa

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

cat <<EOD >> ~/.bashrc
export PS1='\[\e]0;\h\a\] \[\e[0;32m\][\A]\[\e[0m\] \[\e[0;35m\]REMOTE:\h\[\e[0m\] \[\e[1;31m\][PROD]\[\e[0m\]\[\e[0m\] in \[\e[1;33m\]\w\[\e[0m\] $ 
EOD

cat <<EOD >> ~/.bash_aliases
# general
alias current='cd /var/www/html/current'
alias history='cd /var/www/html/releases'
alias taillogs="cd /var/www/html/current && tail -f -n250 storage/logs/laravel"
alias tailsuper="cd /var/www/html/current && tail -f -n250 storage/logs/worker.log"
# APACHE STUFF
alias reload-apache='sudo systemctl reload apache2'
alias restart-apache='sudo systemctl restart apache2'
alias areload='sudo systemctl reload apache2'
alias arestart='sudo systemctl restart apache2'
# Supervisor Stuff
alias restart-super='sudo supervisorctl restart all'
# aliases for directory traversal
alias c='clear'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
# Alter the ls command
alias ls='ls -ac'
alias lls='ls -lac'
alias la="ls --color -lAGbh"
alias ll="ls -lah --color" # List all, with human readable filesizes
# Artisan aliases
alias art='php artisan'
#composer
alias cu="composer update"
# Phillips
alias tree="find . -print | sort -r | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias rst='source ~/.bashrc'
alias statusall='service --status-all'
alias superstatus="sudo systemctl status supervisor"
EOD

sudo timedatectl set-timezone America/Denver

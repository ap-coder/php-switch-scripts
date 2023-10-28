#!/usr/bin/env bash
echo "Running as user: $(whoami)"

set -euo

# Ensure the script is run as ubuntu user
if [ "$(whoami)" != "ubuntu" ]; then
    echo "Script must be run as user: ubuntu"
    exit 1
fi

# Navigate to the ubuntu user home directory
cd /home/ubuntu || exit


command_exists() {
    command -v "$1" >/dev/null 2>&1;
}

# Ensure sudo is used for commands needing root access
sudo apt update -y

if ! command_exists apache2; then
    sudo add-apt-repository -y ppa:ondrej/apache2
    sudo apt update
fi

# Using 'sudo -u ubuntu -H' for all commands related to the ubuntu user
if [ ! -d "/home/ubuntu/php/php-switch-scripts" ]; then
    sudo -u ubuntu -H git clone https://github.com/ap-coder/php-switch-scripts.git /home/ubuntu/php/php-switch-scripts || { echo "Failed to clone repository"; exit 1; }
    sudo -u ubuntu -H bash /home/ubuntu/php/php-switch-scripts/setup.sh
    sudo -u ubuntu -H bash /home/ubuntu/php/php-switch-scripts/switch-to-php-8.1.sh
else
    echo "Repository already cloned"
fi

# Install necessary packages
sudo DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends libmagickwand-dev apache2 libapache2-mod-php imagemagick ghostscript-x supervisor software-properties-common unzip zip redis-server
sudo a2enmod rewrite

# Composer install
if ! command_exists composer; then
    wget -O composer-setup.php https://getcomposer.org/installer
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    sudo chmod +x /usr/local/bin/composer
    sudo composer self-update
fi

# SSH and directory setup for ubuntu user
sudo -u ubuntu -H mkdir -p /home/ubuntu/www/html/public

SSH_EMAIL="dev@mmi.io"

if [ ! -f /home/ubuntu/.ssh/id_rsa ]; then
    sudo -u ubuntu -H ssh-keygen -t rsa -b 4096 -C "${SSH_EMAIL}" -N "" -f /home/ubuntu/.ssh/id_rsa
fi

# Start ssh-agent for ubuntu user
sudo -u ubuntu -H bash -c 'eval $(ssh-agent -s) && ssh-add ~/.ssh/id_rsa'

# Bashrc and alias setup for ubuntu user
sudo -u ubuntu bash -c "cat <<'EOD' >> /home/ubuntu/.bashrc
export PS1='\[\e]0;\h\a\] \[\e[0;32m\][\A]\[\e[0m\] \[\e[0;35m\]REMOTE:\h\[\e[0m\] \[\e[1;31m\][PROD]\[\e[0m\]\[\e[0m\] in \[\e[1;33m\]\w\[\e[0m\] \\$ '
EOD"

sudo -u ubuntu bash -c "cat <<'EOD' >> /home/ubuntu/.bash_aliases
alias current='cd /var/www/html/current'
alias stage='cd /var/www/html/stage/current'
alias develop='cd /var/www/html/develop/current'
alias history='cd /var/www/html/releases'
alias taillogs='cd /var/www/html/current && tail -f -n250 storage/logs/laravel'
alias tailsuper='cd /var/www/html/current && tail -f -n250 storage/logs/worker.log'
alias reload-apache='sudo systemctl reload apache2'
alias restart-apache='sudo systemctl restart apache2'
alias areload='sudo systemctl reload apache2'
alias arestart='sudo systemctl restart apache2'
alias restart-super='sudo supervisorctl restart all'
alias c='clear'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ls='ls -ac'
alias lls='ls -lac'
alias la='ls --color -lAGbh'
alias art='php artisan'
alias cu='composer update'
alias rst='source ~/.bashrc'
alias statusall='service --status-all'
alias superstatus='sudo systemctl status supervisor'
EOD"
sudo timedatectl set-timezone America/Denver
sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc
sudo chown ubuntu:ubuntu /home/ubuntu/.bash_aliases
sudo chown -R ubuntu:ubuntu /home/ubuntu/ /var/www/
sudo chmod -R 755 /home/ubuntu/ /var/www/

source /home/ubuntu/.bash_aliases
source /home/ubuntu/.bashrc
echo "The script ran successfully!"

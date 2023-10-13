#!/bin/bash

# Ensure the script is run as ubuntu user
if [ "$(whoami)" != "ubuntu" ]; then
    echo "Script must be run as user: ubuntu"
    exit 1
fi

# Navigate to the ubuntu user home directory
cd /home/ubuntu || exit

# Append to .bashrc
cat <<EOD >> /home/ubuntu/.bashrc
export PS1='\[\e]0;\h\a\] \[\e[0;32m\][\A]\[\e[0m\] \[\e[0;35m\]REMOTE:\h\[\e[0m\] \[\e[1;31m\][PROD]\[\e[0m\]\[\e[0m\] in \[\e[1;33m\]\w\[\e[0m\] \$ '
EOD

# Append to .bash_aliases
cat <<EOD >> /home/ubuntu/.bash_aliases
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

# Ensure that ubuntu:ubuntu owns the modified files
sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc
sudo chown ubuntu:ubuntu /home/ubuntu/.bash_aliases

# Ensure that script exits if cd fails
set -e

echo "The script ran successfully!"

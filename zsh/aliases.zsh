alias reload!='. ~/.zshrc'
alias chromeos='sudo cgpt add -i 6 -P 0 -S 0 /dev/sda;sudo reboot'
alias 1password='/opt/google/chrome/chrome --allow-file-access-from-files file:///home/user/Dropbox/misc/1Password.agilekeychain/1Password.html'
alias upall='git pull && bundle && rake db:migrate parallel:prepare'
alias cdd='cd ~/Desktop'
alias privdrop='encfs ~/Dropbox/private.encfs ~/private_box'
alias bpkeys='encfs ~/Google\ Drive/access_keys.encfs ~/betterplace_keys'
hot() { ssh hotwater@web$1 }
web() { ssh web$1 }

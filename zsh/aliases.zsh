alias reload!='. ~/.zshrc'
alias chromeos='sudo cgpt add -i 6 -P 0 -S 0 /dev/sda;sudo reboot'
alias 1password='/opt/google/chrome/chrome --allow-file-access-from-files file:///home/user/Dropbox/misc/1Password.agilekeychain/1Password.html'
alias upall='git pull && bundle && rake db:migrate parallel:prepare'
alias cdd='cd ~/Desktop'
alias privdrop='encfs ~/Dropbox/private.encfs ~/private_box'
alias bpkeys='encfs ~/Google\ Drive/access_keys.encfs ~/betterplace_keys'
bps() { ssh betterplace@bp-$1.betterops.de }
epo() { ssh betterplace@epo-$1.betterops.de }
dha-bps() { ssh daniel.hahn@bp-$1.betterops.de }
dha-epo() { ssh daniel.hahn@epo-$1.betterops.de }

alias reload!='. ~/.zshrc'
alias upall='git pull && bundle && bin/yarn && rake db:migrate parallel:prepare'
alias cdd='cd ~/Desktop'
alias privdrop='encfs ~/Dropbox/private.encfs ~/private_box'
alias bpkeys='encfs ~/Google\ Drive/access_keys.encfs ~/betterplace_keys'
bps() { ssh betterplace@bp-$1.betterops.de }
epo() { ssh betterplace@epo-$1.betterops.de }
dha-bps() { ssh daniel.hahn@bp-$1.betterops.de }
dha-epo() { ssh daniel.hahn@epo-$1.betterops.de }

# Enforce use of the gpg2 agent, instead of others that may be around...
/usr/local/opt/gpg2/bin/gpg-connect-agent /bye
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
. $HOME/.gpg-agent-info

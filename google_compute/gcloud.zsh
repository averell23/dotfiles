PREFIX=`brew --prefix`
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$PREFIX/share/google-cloud-sdk/path.zsh.inc" ]; then . "$PREFIX/share/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$PREFIX/share/google-cloud-sdk/completion.zsh.inc" ]; then . "$PREFIX/share/google-cloud-sdk/completion.zsh.inc"; fi

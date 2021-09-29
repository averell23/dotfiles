PREFIX=`brew --prefix`
if [[ -d "$PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]]; then
  source "$PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "$PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

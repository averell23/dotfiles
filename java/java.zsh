if test -f /usr/libexec/java_home
then
  export JAVA_HOME=`/usr/libexec/java_home`
fi
if test -d "$HOME/.jenv/bin"
then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi
